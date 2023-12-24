//
//  WeatherCardsView.swift
//  WellnessAI
//
//  Created by Shubham Chawla on 12/21/23.
//

import SwiftUI

struct WeatherCardsView: View {
    
    @Environment(\.managedObjectContext) var context
    @StateObject private var viewModel = ViewModel()
    
    var body: some View {
        HStack {
            Image(systemName: "cloud.sun")
            Text("Weather Cards")
            Spacer()
            Button {
                viewModel.refreshWeatherInformation(context: context, force: true)
            } label: {
                if viewModel.isAwaitingAPIResponse {
                    ProgressView()
                } else {
                    Image(systemName: "arrow.clockwise")
                }
            }
            .disabled(viewModel.isAwaitingAPIResponse)
        }
        .font(.subheadline)
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
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
        .padding(EdgeInsets(
            top: 8, leading: 0, bottom: 8, trailing: 0
        ))
        .onAppear {
            viewModel.refreshWeatherInformation(context: context)
        }
    }
}
