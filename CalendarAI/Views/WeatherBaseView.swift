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
    @EnvironmentObject var weatherService: WeatherService
    
    @State private var isLoadingNotifications = true
    @State var weather: ResponseBody?
    
    var body: some View {
        VStack {
            if let weather = weather {
                WeatherDetailView(weather: weather)
            } else {
                VStack {
                    ProgressView()
                    Text("Fetching weather data...")
                }
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
