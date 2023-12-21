//
//  WeatherCardsView.swift
//  WellnessAI
//
//  Created by Shubham Chawla on 12/21/23.
//

import SwiftUI

struct WeatherCardsView: View {
    
    @StateObject private var viewModel = ViewModel()
    
    var body: some View {
        HStack {
            Image(systemName: "cloud.sun")
            Text("Weather Cards")
        }
        .font(.subheadline)
        HStack {
            WeatherCardView()
                .frame(width: 300)
            VStack {
                Button {
                    
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
                .padding()
            }
            .font(.title)
        }
        .padding(EdgeInsets(
            top: 8, leading: 0, bottom: 8, trailing: 0
        ))
    }
}

#Preview {
    WeatherCardsView()
}
