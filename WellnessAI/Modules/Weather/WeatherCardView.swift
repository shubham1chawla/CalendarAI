//
//  WeatherCardView.swift
//  WellnessAI
//
//  Created by Shubham Chawla on 12/21/23.
//

import SwiftUI

struct WeatherCardView: View {
    
    let userSession: UserSession
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: "location")
                Text(userSession.weather?.locationName ?? "Unknown")
            }
            .font(.caption)
            .padding()
            HStack(alignment: .bottom, spacing: 8) {
                VStack(alignment: .trailing) {
                    Text(userSession.weather?.weatherMain ?? "Unknown")
                        .font(.headline)
                    Text((userSession.weather?.weatherDescription ?? "Unknown").capitalized)
                        .font(.caption)
                }
                Image(systemName: userSession.weather?.iconSystemName ?? "questionmark")
                    .font(.largeTitle)
                VStack(alignment: .leading) {
                    Text("\(userSession.weather?.currentTemp ?? 0, specifier: "%.2f")° C")
                        .font(.headline)
                    Text("Feels like \(userSession.weather?.feelsLikeTemp ?? 0, specifier: "%.2f")° C")
                        .font(.caption)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: "thermometer.low")
                    Text("Minimum Temperature")
                    Spacer()
                    Text("\(userSession.weather?.minTemp ?? 0, specifier: "%.2f")° C")
                }
                HStack {
                    Image(systemName: "thermometer.high")
                    Text("Maximum Temperature")
                    Spacer()
                    Text("\(userSession.weather?.maxTemp ?? 0, specifier: "%.2f")° C")
                }
                HStack {
                    Image(systemName: "barometer")
                    Text("Pressure")
                    Spacer()
                    Text("\(userSession.weather?.pressure ?? 0, specifier: "%.2f") hPa")
                }
                HStack {
                    Image(systemName: "humidity")
                    Text("Humidity")
                    Spacer()
                    Text("\(userSession.weather?.humidity ?? 0, specifier: "%.2f") %")
                }
                HStack {
                    Image(systemName: "eye")
                    Text("Visibility")
                    Spacer()
                    Text("\(userSession.weather?.visibility ?? 0, specifier: "%.2f") m")
                }
                HStack {
                    Image(systemName: "wind")
                    Text("Wind Speed")
                    Spacer()
                    Text("\(userSession.weather?.windSpeed ?? 0, specifier: "%.2f") m/s")
                }
            }
            .padding()
            .font(.subheadline)
            HStack {
                Image(systemName: "clock")
                Text(userSession.timestamp!.formatted(relativeTo: Date()))
            }
            .font(.caption)
            .padding()
        }
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 4))
    }
}

