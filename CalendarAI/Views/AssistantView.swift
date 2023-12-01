//
//  AssistantView.swift
//  CalendarAI
//
//  Created by Shubham Chawla on 11/24/23.
//

import SwiftUI
import EventKit

struct AssistantView: View {
    
    @EnvironmentObject var calendarService: CalendarService
    @EnvironmentObject var generativeAIService: GenerativeAIService
    @EnvironmentObject var dataService: DataService
    @EnvironmentObject var locationService: LocationService
    
    @State private var prompts: [String] = []
    @State private var isLoading: Bool = true
    
    var body: some View {
        NavigationView {
            List {
                if isLoading {
                    Text("Loading...")
                }
                ForEach(prompts, id: \.self) { prompt in
                    VStack(alignment: .leading) {
                        Text(prompt)
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
            .navigationTitle("Assistant")
        }
        .onAppear {
            self.prompts = []
            let events = calendarService.getCalendarEvents()
            for event in events {
                generativeAIService.classifyEvent(event: event) { classification in
                    guard let classification = classification else {
                        return
                    }
                    dataService.saveClassification(event: event, result: classification)
                    var placeType = ""
                    if classification == "celebration" {
                        placeType = "shopping_mall"
                    } else if classification == "health" {
                        placeType = "hospital"
                    }
                    if placeType.isEmpty {
                        generateNotification(event: event, place: nil)
                    } else {
                        locationService.getNearbyPlaces(placeType: placeType) { result in
                            switch result {
                            case .success(let response):
                                let place = response.results[0]
                                generateNotification(event: event, place: place)
                            case .failure(let error):
                                print(error.localizedDescription)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func generateNotification(event: EKEvent, place: GoogleNearbyPlace?) -> Void {
        generativeAIService.generateNotificationContent(event: event, place: place) { prompt in
            if let prompt = prompt {
                print(print)
                self.prompts.append(prompt)
                self.isLoading = false
            }
        }
    }
}

#Preview {
    AssistantView()
}
