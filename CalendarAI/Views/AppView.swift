//
//  AppView.swift
//  CalendarAI
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
            .navigationTitle("CalendarAI")
            .toolbar {
                HStack {
                    NavigationLink {
                        Text("Settings")
                    } label: {
                        Image(systemName: "gear")
                    }
                }
            }
        }
    }
}

#Preview {
    AppView()
}
