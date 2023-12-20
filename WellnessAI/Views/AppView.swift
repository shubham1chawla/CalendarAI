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
            ScrollView(.vertical) {
                VStack(alignment: .leading) {
                    AINotificationsView()
                    HealthCardsView()
                }
            }
            .padding()
            .navigationTitle("WellnessAI")
        }
    }
}

#Preview {
    AppView()
}
