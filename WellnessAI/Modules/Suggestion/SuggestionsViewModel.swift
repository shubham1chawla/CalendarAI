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

enum SuggestionTag: String, CaseIterable {
    case Shopping
    case Health
    case Work
    case Personal
}

extension SuggestionsView {
    @MainActor class ViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
        
        private var context: NSManagedObjectContext?
        private var locationManager: CLLocationManager?
        private let eventStore: EKEventStore = EKEventStore()
        private let defaults = UserDefaults.standard
        
        @Published private(set) var hasCalendarAccess: Bool = false
        @Published private(set) var isUpdatingSuggestions: Bool = false
        @Published private(set) var errorMessage: String? = nil
        
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
                    try await updateSuggestions(location: currentLocation)
                } catch {
                    errorMessage = error.localizedDescription
                }
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
        private func updateSuggestions(location: CLLocation) async throws {
            
        }
        
        private func getCurrentWeather() -> Weather? {
            guard let context = context else { return nil }
            let userSessions = try? context.fetch(UserSession.fetchCurrentRequest())
            return userSessions?.first?.weather
        }
        
        private func getUpcomingEKEvents() -> [EKEvent] {
            let startDate = Date()
            let endDate = startDate + 7 * 24 * 3600
            let calendars = eventStore.calendars(for: .event)
            let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: calendars)
            return eventStore.events(matching: predicate)
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
