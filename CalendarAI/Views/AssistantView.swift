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
    @EnvironmentObject var weatherService: WeatherService
    
    @State private var prompts: [String] = []
    @State private var isLoadingNotifications = true
    
    var body: some View {
        NavigationView {
            if locationService.coordinate == nil || isLoadingNotifications {
                VStack {
                    ProgressView()
                    Text(locationService.coordinate == nil ? "Updating Location..." : "Loading notifications...")
                }
                .navigationTitle("Assistant")
                .onAppear {
                    if locationService.coordinate == nil {
                        locationService.registerListener {
                            if isLoadingNotifications {
                                generateNotifications()
                            }
                        }
                    }
                }
            } else {
                List {
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
                .toolbar {
                    HStack {
                        NavigationLink {
                            WeatherBaseView()
                        } label: {
                            Image(systemName: "cloud.sun.fill")
                        }
                    }
                }
            }
        }
    }
    
    private func generateNotifications() -> Void {
        self.prompts = []
        let events = calendarService.getCalendarEvents()
        for event in events {
            let optional = dataService.getClassification(for: event)
            if let classification = optional {
                generateNotifications(event: event, classification: classification)
            } else {
                generativeAIService.classifyEvent(event: event) { result in
                    guard let result = result else {
                        return
                    }
                    let classification = dataService.saveClassification(event: event, result: result)
                    generateNotifications(event: event, classification: classification)
                }
            }
        }
    }
    
    private func generateNotifications(event: EKEvent, classification: AIClassification) -> Void {
        var placeType = ""
        if classification.result == "celebration" {
            placeType = "shopping_mall"
        } else if classification.result == "health" {
            placeType = "hospital"
        }
        if placeType.isEmpty || locationService.coordinate == nil {
            generateNotifications(event: event, classification: classification, place: nil)
        } else {
            locationService.getNearbyPlaces(placeType: placeType) { result in
                switch result {
                case .success(let response):
                    let place = getBestNearbyPlace(response: response)
                    print(place.name)
                    generateNotifications(event: event, classification: classification, place: place)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    private func generateNotifications(event: EKEvent, classification: AIClassification, place: GoogleNearbyPlace?) -> Void {
        generativeAIService.generateNotificationContent(event: event, classification: classification, place: place) { prompt in
            if let prompt = prompt {
                print(prompt)
                self.prompts.append(prompt)
                self.isLoadingNotifications = false
            }
        }
    }
    
    private func getBestNearbyPlace(response: GoogleNearbyPlacesResponse) -> GoogleNearbyPlace {
        var place = response.results[0]
        for idx in 1...response.results.count-1 {
            let otherPlace = response.results[idx]
            if ((otherPlace.rating ?? 0) > (place.rating ?? 0)) && ((otherPlace.user_ratings_total ?? 0) > (place.user_ratings_total ?? 0)) {
                place = otherPlace
            }
        }
        return place
    }
    
}

#Preview {
    AssistantView()
}
