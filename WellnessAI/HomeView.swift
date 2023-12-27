//
//  HomeView.swift
//  WellnessAI
//
//  Created by Shubham Chawla on 12/16/23.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading) {
                    SuggestionsView().padding(.horizontal)
                    HealthCardsView().padding(.horizontal)
                    WeatherCardsView().padding(.horizontal)
                }
            }
            .navigationTitle("Wellness.ai")
        }
    }
}

#Preview {
    HomeView()
}
