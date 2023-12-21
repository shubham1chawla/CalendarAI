//
//  AppView.swift
//  WellnessAI
//
//  Created by Shubham Chawla on 12/16/23.
//

import SwiftUI

struct AppView: View {
    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading) {
                    AINotificationsView().padding(.horizontal)
                    HealthCardsView().padding(.horizontal)
                    WeatherCardsView().padding(.horizontal)
                }
            }
            .navigationTitle("Wellness.ai")
        }
    }
}

#Preview {
    AppView()
}
