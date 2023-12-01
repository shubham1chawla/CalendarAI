//
//  CalendarView.swift
//  CalendarAI
//
//  Created by Shubham Chawla on 11/24/23.
//

import SwiftUI
import EventKit

struct CalendarView: View {
    @EnvironmentObject var calendarService: CalendarService
    var body: some View {
            List {
                ForEach(calendarService.events, id: \.self) { event in
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
                calendarService.fetchEvents()
            }
        }
    func formatEventDate(event: EKEvent) -> String {
        if event.isAllDay {
            return event.startDate.formatted(date: .numeric, time: .omitted)
        }
        return "\(event.startDate.formatted()) - \(event.endDate.formatted())"
    }
}


#Preview {
    CalendarView()
}
