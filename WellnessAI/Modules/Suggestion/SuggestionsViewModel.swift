//
//  SuggestionsViewModel.swift
//  WellnessAI
//
//  Created by Shubham Chawla on 12/27/23.
//

import Foundation
import CoreLocation
import CoreData
import EventKit

extension SuggestionsView {
    @MainActor class ViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
        
        private var context: NSManagedObjectContext?
        private var locationManager: CLLocationManager?
        private let eventStore: EKEventStore = EKEventStore()
        
        @Published private(set) var hasCalendarAccess: Bool = false
        @Published private(set) var isUpdatingSuggestions: Bool = false
        @Published private(set) var errorMessage: String? = nil
        @Published private(set) var userSessions: [UserSession] = []
        
        private var hospital: GoogleNearbyPlace? = nil
        private var mall: GoogleNearbyPlace? = nil
        private var weather: Weather? = nil
        
        var isError: Bool {
            return !(errorMessage ?? "").isEmpty
        }
        
        var suggestions: [Suggestion] {
            guard
                let userSession = userSessions.first,
                let set = userSession.suggestions,
                let suggestions = set.allObjects as? [Suggestion]
            else {
                return []
            }
            return suggestions
        }
        
        override init() {
            super.init()
            requestFullAccesstoCalendarEvents()
        }
        
        func refreshSuggestions(context: NSManagedObjectContext, force: Bool = false) -> Void {
            guard hasCalendarAccess else { return }
            self.context = context
            errorMessage = nil
            
            // Loading sessions with suggestions from database
            setUserSessionsWithSuggestions()
            
            if shouldCallOpenWeatherAPI(force: force) {
                locationManager = CLLocationManager()
                locationManager?.delegate = self
                locationManager?.desiredAccuracy = kCLLocationAccuracyBest
                locationManager?.requestWhenInUseAuthorization()
            }
        }
        
        private func shouldCallOpenWeatherAPI(force: Bool) -> Bool {
            if isUpdatingSuggestions { return false }
            if userSessions.isEmpty { return true }
            let userSession = userSessions.first
            let timestamp = userSession?.timestamp ?? Date.now
            let timeout = force ? APIConstants.API_THROTTLING_FORCE_TIMEOUT : APIConstants.API_THROTTLING_REGULAR_TIMEOUT
            return abs(Int(timestamp.timeIntervalSinceNow)) > timeout
        }
        
        nonisolated func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
            Task { @MainActor in
                switch status {
                case .authorized:
                    fallthrough
                case .authorizedAlways:
                    fallthrough
                case .authorizedWhenInUse:
                    locationManager?.startUpdatingLocation()
                    break
                default:
                    errorMessage = "Unable to access your location!"
                }
            }
        }
        
        nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            guard let currentLocation = locations.last else { return }
            manager.stopUpdatingLocation()
            Task { @MainActor in
                guard !isUpdatingSuggestions else { return }
                isUpdatingSuggestions = true
                do {
                    defer {
                        isUpdatingSuggestions = false
                    }
                    try await setNearbyPlacesAndWeather(currentLocation)
                    try await saveSuggestions()
                    setUserSessionsWithSuggestions()
                } catch {
                    errorMessage = error.localizedDescription
                }
            }
        }
        
        private func setNearbyPlacesAndWeather(_ location: CLLocation) async throws -> Void {
            let hospitals = try await GoogleNearbyPlacesRequest(location: location, type: .hospital).fetch()
            let malls = try await GoogleNearbyPlacesRequest(location: location, type: .shopping_mall).fetch()
            await MainActor.run {
                self.hospital = GoogleNearbyPlace.getBestPlace(from: hospitals)
                self.mall = GoogleNearbyPlace.getBestPlace(from: malls)
                self.weather = getLatestWeather(location: location)
            }
        }
        
        private func saveSuggestions() async throws -> Void {
            guard let context = context else { return }
            
            // Clearing old suggestions in current user session
            let userSession = UserSession.getCurrent(context: context)
            userSession.suggestions = []
            try context.save()
            
            // Generating suggestions from events
            await saveSuggestionsFromCalendarEvents()
            
            // Generating suggestions from health cards
            await saveSuggestionsFromHealthInformation()
        }
        
        private func saveSuggestionsFromCalendarEvents() async -> Void {
            let events = eventStore.upcomingEvents()
            if events.isEmpty {
                // Saving suggestion for empty calendar and well-being
                await saveSuggestionEmptyCalendar()
            } else {
                // Saving suggestion from the upcoming event
                if let event = events.first {
                    await saveSuggestion(forEvent: event)
                }
                
                // Adding suggestion if busy week
                if events.count > SuggestionConstants.BUSY_WEEK_EVENTS_COUNT {
                    await saveSuggestionBusyCalendar(forEvents: events)
                }
            }
        }
        
        private func saveSuggestionEmptyCalendar() async -> Void {
            guard 
                let context = context,
                let response = try? await ChatGPTAPIRequest.emptyCalendarRequest(weather: weather).fetch(),
                let content = response.getContent()
            else { return }
            let suggestion = Suggestion.fromCalendar(context: context, content: content)
            if let weather = weather {
                [
                    FineTuneParameter.ofWeather(context: context, weather: weather),
                    FineTuneParameter.ofEmptyCalendar(context: context)
                ].forEach { $0.suggestion = suggestion }
            }
            try? context.save()
        }
        
        private func saveSuggestion(forEvent event: EKEvent) async -> Void {
            guard let context = context else { return }
            do {
                if
                    let response = try await ChatGPTAPIRequest.classifyRequest(ofEvent: event)?.fetch(),
                    let classification = response.getClassification()
                {
                    var request: ChatGPTAPIRequest? = nil
                    var parameters: [FineTuneParameter] = [FineTuneParameter.ofCalendar(context: context, event: event)]
                    switch classification {
                    case .Celebration:
                        request = ChatGPTAPIRequest.shoppingRequest(forEvent: event, atPlace: mall, weather: weather)
                        mall != nil ? parameters.append(FineTuneParameter.ofPlace(context: context, place: mall!)) : nil
                        weather != nil ? parameters.append(FineTuneParameter.ofWeather(context: context, weather: weather!)) : nil
                        break
                    case .Health:
                        request = ChatGPTAPIRequest.healthRequest(forEvent: event, atPlace: hospital, weather: weather)
                        hospital != nil ? parameters.append(FineTuneParameter.ofPlace(context: context, place: hospital!)) : nil
                        weather != nil ? parameters.append(FineTuneParameter.ofWeather(context: context, weather: weather!)) : nil
                        break
                    case .Work:
                        break
                    case .Personal:
                        break
                    }
                    if let request = request, let content = try await request.fetch().getContent() {
                        let suggestion = Suggestion.fromCalendar(context: context, content: content)
                        parameters.forEach { $0.suggestion = suggestion }
                        try context.save()
                    }
                }
            } catch {
                print(error.localizedDescription)
            }
        }
        
        private func saveSuggestionBusyCalendar(forEvents events: [EKEvent]) async -> Void {
            guard 
                let context = context,
                let response = try? await ChatGPTAPIRequest.busyCalendarRequest(events: events).fetch(),
                let content = response.getContent()
            else { return }
            let suggestion = Suggestion.fromCalendar(context: context, content: content)
            [FineTuneParameter.ofBusyCalendar(context: context, events: events)].forEach { $0.suggestion = suggestion }
            try? context.save()
        }
        
        private func saveSuggestionsFromHealthInformation() async -> Void {
            let userSessions = getUserSessionsWithHealthInformation()
            
            // Saving suggestions with stale or no health information
            await saveSuggestionStaleOrNoHealthInformation(userSessions)
            
            // TODO: If a symptom is recorded more than X times in last week, suugest user for check-up
            
            // TODO: If heart rate is high in last week, suggest user for check-up
            
            // TODO: If resp rate is high in last week, suggest user for check-up
        }
        
        private func saveSuggestionStaleOrNoHealthInformation(_ userSessions: [UserSession]) async -> Void {
            if 
                !userSessions.isEmpty,
                let userSession = userSessions.first,
                let timestamp = userSession.timestamp,
                abs(Int(timestamp.timeIntervalSinceNow)) < SuggestionConstants.STALE_HEALTH_TIME_INTERVAL
            { return }
            let userSession: UserSession? = userSessions.isEmpty ? nil : userSessions.first
            guard
                let context = context,
                let response = try? await ChatGPTAPIRequest.staleHealthInformationRequest(userSession: userSession).fetch(),
                let content = response.getContent()
            else { return }
            let suggestion = Suggestion.fromHealth(context: context, content: content)
            [FineTuneParameter.ofStaleHealthInformation(context: context, userSession: userSession)].forEach { $0.suggestion = suggestion }
            try? context.save()
        }
        
        private func setUserSessionsWithSuggestions() -> Void {
            guard let context = context else { return }
            var userSessions: [UserSession] = []
            for userSession in try! context.fetch(UserSession.fetchWithSuggestionsRequest()) {
                userSessions.append(userSession)
            }
            self.userSessions = userSessions
        }
        
        private func getUserSessionsWithHealthInformation() -> [UserSession] {
            guard let context = context else { return [] }
            return (try? context.fetch(UserSession.fetchWithHealthRequest())) ?? []
        }
        
        private func getLatestWeather(location: CLLocation) -> Weather? {
            guard let context = context else { return nil }
            let userSessions = try? context.fetch(UserSession.fetchWithWeatherRequest())
            
            // Checking if weather is a) not too old b) roughly same coordinates
            guard
                let userSessions = userSessions,
                let userSession = userSessions.first,
                userSession.timestamp! > Date.now - 3600,
                let weather = userSession.weather,
                abs(weather.latitude - location.coordinate.latitude) < 0.5,
                abs(weather.longitude - location.coordinate.longitude) < 0.5
            else {
                return nil
            }
            return weather
        }
        
        private func requestFullAccesstoCalendarEvents() -> Void {
            switch EKEventStore.authorizationStatus(for: .event) {
            case .notDetermined:
                Task {
                    var granted = false
                    do { granted = try await eventStore.requestFullAccessToEvents() } catch { granted = false }
                    if !granted {
                        await MainActor.run {
                            errorMessage = "Permissions denied to access your calendar!"
                        }
                    }
                }
            case .fullAccess:
                self.hasCalendarAccess = true
                break
            default:
                errorMessage = "Permissions denied to access your calendar!"
            }
        }
        
    }
}
