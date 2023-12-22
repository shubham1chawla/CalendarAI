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
        }
        .font(.subheadline)
        .onAppear {
            viewModel.refreshWeatherInformation(context: context)
        }
        if viewModel.isError {
            ErrorWeatherCardView(errorMessage: viewModel.errorMessage)
        }
        else if viewModel.userSessions.isEmpty {
            LoadingWeatherCardView()
        }
        else {
            HStack {
                WeatherCardView(userSession: viewModel.userSessions.first!)
                    .frame(width: 300)
                VStack {
                    Button {
                        viewModel.refreshWeatherInformation(context: context)
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
}
