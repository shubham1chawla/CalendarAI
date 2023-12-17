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
            VStack(alignment: .leading) {
                AINotificationsView()
                Spacer()
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
