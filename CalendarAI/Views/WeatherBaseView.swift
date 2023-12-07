//
//  WeatherBaseView.swift
//  CalendarAI
//
//  Created by Aashna Budhiraja on 11/22/23.
//

import SwiftUI
import CoreLocation

struct WeatherBaseView: View {
    @EnvironmentObject var locationService: LocationService
    @State private var isLoadingNotifications = true

    struct WeatherLoadingView2: View {
        var body: some View {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    var weatherService = WeatherService()
    @State var weather: ResponseBody?
    
    var body: some View {
        VStack {
            if let coordinate = locationService.coordinate {
                if let weather = weather {
                    WeatherDetailView(weather: weather)
                                } else {
                                    Text("Fetching weather data...")
                                }
            } else {
                Text("Fetching location...")
            }
        }
        .onAppear {
            fetchWeather()
        }
    }
    func fetchWeather() {
        guard let coordinate = locationService.coordinate else {
            print("No coordinates available.")
            return
        }

        Task {
            do {
                weather = try await weatherService.getCurrentWeather(latitude: coordinate.latitude, longitude: coordinate.longitude)
                print("Weather data fetched successfully: \(weather)")
            } catch {
                print("Error fetching weather: \(error)")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        WeatherBaseView()
    }
}
