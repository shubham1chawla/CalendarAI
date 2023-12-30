//
//  WeatherCardsView.swift
//  WellnessAI
//
//  Created by Shubham Chawla on 12/21/23.
//

import SwiftUI

struct WeatherCardsView: View {
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        HStack {
            Image(systemName: "cloud.sun")
            Text("Weather Cards")
        }
        .font(.subheadline)
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                if viewModel.isAwaitingAPIResponse {
                    HStack(alignment: .center) {
                        ProgressView()
                    }
                    .controlSize(.large)
                    .padding()
                }
                Group {
                    if viewModel.isError {
                        ErrorWeatherCardView(errorMessage: viewModel.errorMessage)
                    } else if viewModel.userSessions.isEmpty {
                        LoadingWeatherCardView()
                    } else {
                        WeatherCardView(weather: viewModel.userSessions.first!.weather!)
                            
                    }
                }
                .frame(width: 300)
            }
        }
        .padding(EdgeInsets(
            top: 8, leading: 0, bottom: 8, trailing: 0
        ))
    }
}
