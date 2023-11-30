//
//  CalendarView.swift
//  CalendarAI
//
//  Created by Shubham Chawla on 11/24/23.
//

import SwiftUI
import EventKit

struct CalendarView: View {
    
    private var store = EKEventStore()
    @State var events: [EKEvent] = []
    
    init() {
        checkPermissions()
    }
    
    private func checkPermissions() {
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
    
    var body: some View {
//        Text("Calender Events")
        List {
            ForEach(events, id: \.self) { event in
                VStack(alignment: .leading) {
                    Text(event.title)
                        .font(.headline)
                    HStack {
                        Image(systemName: "circle.fill")
                            .foregroundColor(Color(cgColor: event.calendar.cgColor))
                            .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: -5))
                        Text(formatEventDate(event: event))
                    }
                    .font(.caption)
                }
                .listRowSeparator(.hidden)
                .listRowBackground(
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Material.ultraThin)
                        .padding(EdgeInsets(top: 4, leading: 20, bottom: 4, trailing: 20))
                )
                .padding(EdgeInsets(top: 15, leading: 20, bottom: 15, trailing: 20))
            }
        }
        .listStyle(.plain)
        .onAppear {
            let startDate = Date()
            let endDate = Date(timeIntervalSinceNow: 30 * 24 * 3600)
            let calendars = store.calendars(for: .event)
            let predicate = store.predicateForEvents(withStart: startDate, end: endDate, calendars: calendars)
            var events: [EKEvent] = []
            for event in store.events(matching: predicate) {
                events.append(event)
            }
            self.events = events;
        }
    }
    
    private func formatEventDate(event: EKEvent) -> String {
        if event.isAllDay {
            return event.startDate.formatted(date: .numeric, time: .omitted)
        }
        return "\(event.startDate.formatted()) - \(event.endDate.formatted())"
    }
    
}


#Preview {
    CalendarView()
}
