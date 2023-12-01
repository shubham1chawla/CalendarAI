//
//  CalendarService.swift
//  CalendarAI
//
//  Created by Jai Narula on 11/30/23.
//

import Foundation
import EventKit

class CalendarService: ObservableObject {
    private var store = EKEventStore()
    @Published var events: [EKEvent] = []

    init() {
        checkPermissions()
    }

    func checkPermissions() {
           let status = EKEventStore.authorizationStatus(for: .event)
           switch (status) {
           case .notDetermined:
               store.requestFullAccessToEvents { granted, error in
                   
               }
           case .fullAccess:
               break
           default:
               print("No access! Status: \(status)")
           }
       }

    func formatEventDate(event: EKEvent) -> String {
        if event.isAllDay {
            return event.startDate.formatted(date: .numeric, time: .omitted)
        }
        return "\(event.startDate.formatted()) - \(event.endDate.formatted())"
    }
}
