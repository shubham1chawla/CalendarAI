//
//  WeatherBaseView.swift
//  CalendarAI
//
//  Created by Aashna Budhiraja on 11/22/23.
//

import SwiftUI
import CoreLocation

struct WeatherBaseView: View {
    struct WeatherLoadingView2: View {
        var body: some View {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    @StateObject var locationManager = WeatherLocationService()
    
    var weatherManager = WeatherService()
    @State var weather: ResponseBody?
    
    var body: some View {
        VStack {
            
            if let location = locationManager.location {
                if let weather = weather {
                    WeatherDetailView(weather: weather)
                } else {
                    WeatherLoadingView2()
                        .task {
                            do {
                                weather = try await weatherManager.getCurrentWeather(latitude: location.latitude, longitude: location.longitude)
                            } catch {
                                print("Error:\(error)")
                            }
                            
                        }
                }
            } else {
                if locationManager.isLoading {
                    WeatherLoadingView2()
                } else {
                    WeatherWelcomeView()
                        .environmentObject(locationManager)
                }
            }
           
        }
        .background(Color(red: 0.0, green: 0.2, blue: 0.6))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        WeatherBaseView()
    }
}
