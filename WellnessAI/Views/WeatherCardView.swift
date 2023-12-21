//
//  WeatherCardView.swift
//  WellnessAI
//
//  Created by Shubham Chawla on 12/21/23.
//

import SwiftUI

struct Field {
    let icon: String
    let name: String
    let value: String
}

struct WeatherCardView: View {
    
    private var fields = [
        Field(icon: "thermometer.low", name: "Minimum Temperature", value: "14° C"),
        Field(icon: "thermometer.high", name: "Maximum Temperature", value: "20° C"),
        Field(icon: "wind", name: "Wind Speed", value: "2 m/s"),
        Field(icon: "humidity", name: "Humidity", value: "62 %"),
        Field(icon: "eye", name: "Visibility", value: "10 km"),
        Field(icon: "barometer", name: "Pressure", value: "10 khPa"),
        Field(icon: "cloud.rain", name: "Rain", value: "0 mm"),
        Field(icon: "cloud.snow", name: "Snow", value: "0 mm"),
    ]
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: "location")
                Text("Bhiwadi")
            }
            .font(.caption)
            .padding()
            HStack(alignment: .bottom, spacing: 8) {
                Image(systemName: "cloud.fill")
                    .font(.largeTitle)
                VStack(alignment: .leading) {
                    Text("16° C")
                        .font(.headline)
                    Text("Feels like 15° C")
                        .font(.caption)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            VStack(spacing: 8) {
                ForEach(fields, id:\.name) { field in
                    HStack {
                        Image(systemName: field.icon)
                        Text(field.name)
                        Spacer()
                        Text(field.value)
                    }
                    .font(.subheadline)
                }
            }
            .padding()
            HStack {
                Image(systemName: "clock")
                Text("Updated on \(timeAgoFormat(date: Date()))")
            }
            .font(.caption)
            .padding()
        }
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 4))
    }
}

#Preview {
    WeatherCardView()
}
