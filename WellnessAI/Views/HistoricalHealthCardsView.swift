//
//  HistoricalHealthCardsView.swift
//  WellnessAI
//
//  Created by Shubham Chawla on 12/20/23.
//

import SwiftUI

struct HistoricalHealthCardsView: View {
    
    @ObservedObject var viewModel: HealthCardsView.ViewModel
    
    var body: some View {
        List {
            ForEach(viewModel.userSessions) { userSession in
                NavigationLink {
                    ShareableHealthCardView(userSession: userSession, intensities: viewModel.intensities)
                } label: {
                    Image(systemName: "heart.text.square")
                    Text("Health Card from \(userSession.timestamp!.asTimeAgoFormatted())")
                }
            }
        }
        .navigationTitle("History")
    }
}
