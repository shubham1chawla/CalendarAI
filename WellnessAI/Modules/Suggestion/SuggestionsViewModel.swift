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
        
        func refreshSuggestions(context: NSManagedObjectContext) -> Void {
            guard hasCalendarAccess else { return }
            self.context = context
            errorMessage = nil
            
            locationManager = CLLocationManager()
            locationManager?.delegate = self
            locationManager?.desiredAccuracy = kCLLocationAccuracyBest
            locationManager?.requestWhenInUseAuthorization()
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
                    try await setSuggestions()
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
        private func setSuggestions() async throws -> Void {
            guard let context = context else { return }
            var suggestions: [Suggestion] = []
            
            // Generating suggestions from events
            await getSuggestions(forEvents: eventStore.upcomingEvents()).forEach { suggestions.append($0) }
            
            // Saving new suggestions and loading from database
            try context.save()
            var userSessions: [UserSession] = []
            for userSession in try context.fetch(UserSession.fetchWithSuggestionsRequest()) {
                userSessions.append(userSession)
            }
            self.userSessions = userSessions
        }
        
        /**
         Following use cases are covered while generating suggestions from events -
         1. If no events found, suggest to rest for the week.
         2. if more than 10 events, alert the user of busy week.
         3. Classify the upcoming event and use Google Nearby Places  and weather information to fine tune suggestion
         */
        private func getSuggestions(forEvents events: [EKEvent]) async -> [Suggestion] {
            var suggestions: [Suggestion] = []
            if events.isEmpty {
                // TODO: Generate an enjoy your week suggestion
            } else {
                
                // Adding suggestion from the upcoming event
                if let event = events.first, let suggestion = await getSuggestion(forEvent: event) {
                    suggestions.append(suggestion)
                }
                
                // Adding suggestion if busy week
                if events.count > SuggestionConstants.BUSY_WEEK_EVENTS_COUNT {
                    // TODO: Generate a suggestion of busy week ahead
                }
            }
            return suggestions
        }
        
        private func getSuggestion(forEvent event: EKEvent) async -> Suggestion? {
            guard let context = context else { return nil }
            do {
                if
                    let response = try await ChatGPTAPIRequest.classifyRequest(ofEvent: event)?.fetch(),
                    let classification = response.getClassification()
                {
                    var request: ChatGPTAPIRequest? = nil
                    switch classification {
                    case .Celebration:
                        request = ChatGPTAPIRequest.shoppingRequest(forEvent: event, atPlace: mall, weather: weather)
                        break
                    case .Health:
                        break
                    case .Work:
                        break
                    case .Personal:
                        break
                    }
                    if let request = request, let content = try await request.fetch().getContent() {
                        return Suggestion.fromCalendar(context: context, content: content)
                    }
                }
            } catch {
                print(error.localizedDescription)
            }
            return nil
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
