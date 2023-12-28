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
            if force { return true }
            if userSessions.isEmpty { return true }
            
            let userSession = userSessions.first
            let timestamp = userSession?.timestamp ?? Date.now
            return abs(Int(timestamp.timeIntervalSinceNow)) > APIConstants.API_THROTTLING_TIMEOUT
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
                    await setNearbyPlacesAndWeather(currentLocation)
                    try await saveSuggestions()
                    setUserSessionsWithSuggestions()
                } catch {
                    errorMessage = error.localizedDescription
                }
            }
        }
        
        private func setNearbyPlacesAndWeather(_ location: CLLocation) async -> Void {
            var hospitals: [GoogleNearbyPlace] = []
            var malls: [GoogleNearbyPlace] = []
            do {
                hospitals = try await GoogleNearbyPlacesRequest(location: location, type: .hospital).fetch()
                malls = try await GoogleNearbyPlacesRequest(location: location, type: .shopping_mall).fetch()
            } catch {
                print(error.localizedDescription)
            }
            await MainActor.run {
                self.hospital = GoogleNearbyPlace.getBestPlace(from: hospitals)
                self.mall = GoogleNearbyPlace.getBestPlace(from: malls)
                self.weather = getLatestWeather(location: location)
            }
        }
        
        /**
         Cases to cover for suggestion -
         Events
         - If more than 10 events in a week, suggest a busy week.
         - Tag upcoming event, if shopping use Google Nearby API to find a shopping place.
         - If no upcoming events, simple suggestion of enjoy your time.
         Health
         - If there is no health card in current user session, suggest taking health check.
         - Get the recent 3 health card have same symptom, suggest visiting hospital (Google Nearby API).
         - Get the recent 3 health card have high heart rate/ resp rate, suggest visiting hospital (Google Nearby API).
         */
        private func saveSuggestions() async throws -> Void {
            guard let context = context else { return }
            
            // Clearing old suggestions in current user session
            let userSession = UserSession.getCurrent(context: context)
            userSession.suggestions = []
            try context.save()
            
            // Generating suggestions from events
            await saveSuggestions(forEvents: eventStore.upcomingEvents())
        }
        
        private func saveSuggestions(forEvents events: [EKEvent]) async -> Void {
            if events.isEmpty {
                // TODO: Generate an enjoy your week suggestion
            } else {
                // Saving suggestion from the upcoming event
                if let event = events.first { await saveSuggestion(forEvent: event) }
                
                // Adding suggestion if busy week
                if events.count > SuggestionConstants.BUSY_WEEK_EVENTS_COUNT {
                    // TODO: Generate a suggestion of busy week ahead
                }
            }
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
        
        private func setUserSessionsWithSuggestions() -> Void {
            guard let context = context else { return }
            var userSessions: [UserSession] = []
            for userSession in try! context.fetch(UserSession.fetchWithSuggestionsRequest()) {
                userSessions.append(userSession)
            }
            self.userSessions = userSessions
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
                eventStore.requestFullAccessToEvents { [weak self] granted, error in
                    if let error = error {
                        self?.errorMessage = error.localizedDescription
                        return
                    }
                    guard granted else {
                        self?.errorMessage = "Permissions to the calendar denied!"
                        return
                    }
                }
            case .fullAccess:
                self.hasCalendarAccess = true
                break
            default:
                errorMessage = "Unable to access your calendar!"
            }
        }
        
    }
}
