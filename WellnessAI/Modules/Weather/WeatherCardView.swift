//
//  WeatherCardView.swift
//  WellnessAI
//
//  Created by Shubham Chawla on 12/21/23.
//

import SwiftUI

struct WeatherCardView: View {
    
    let weather: Weather
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: "location")
                Text(weather.locationName ?? "Unknown")
            }
            .font(.caption)
            .padding()
            HStack(alignment: .bottom, spacing: 8) {
                VStack(alignment: .trailing) {
                    Text(weather.weatherMain ?? "Unknown")
                        .font(.headline)
                    Text((weather.weatherDescription ?? "Unknown").capitalized)
                        .font(.caption)
                }
                Image(systemName: weather.iconSystemName ?? "questionmark")
                    .font(.largeTitle)
                VStack(alignment: .leading) {
                    Text("\(weather.currentTemp, specifier: "%.2f")° C")
                        .font(.headline)
                    Text("Feels like \(weather.feelsLikeTemp, specifier: "%.2f")° C")
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
                    Text("\(weather.minTemp, specifier: "%.2f")° C")
                }
                HStack {
                    Image(systemName: "thermometer.high")
                    Text("Maximum Temperature")
                    Spacer()
                    Text("\(weather.maxTemp, specifier: "%.2f")° C")
                }
                HStack {
                    Image(systemName: "barometer")
                    Text("Pressure")
                    Spacer()
                    Text("\(weather.pressure, specifier: "%.2f") hPa")
                }
                HStack {
                    Image(systemName: "humidity")
                    Text("Humidity")
                    Spacer()
                    Text("\(weather.humidity, specifier: "%.2f") %")
                }
                HStack {
                    Image(systemName: "eye")
                    Text("Visibility")
                    Spacer()
                    Text("\(weather.visibility, specifier: "%.2f") m")
                }
                HStack {
                    Image(systemName: "wind")
                    Text("Wind Speed")
                    Spacer()
                    Text("\(weather.windSpeed, specifier: "%.2f") m/s")
                }
            }
            .padding()
            .font(.subheadline)
        }
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 4))
    }
}

