//
//  HealthCardsView.swift
//  WellnessAI
//
//  Created by Shubham Chawla on 12/17/23.
//

import SwiftUI

struct HealthCardsView: View {
    
    @Environment(\.managedObjectContext) var context
    @StateObject private var viewModel = ViewModel()
    
    var body: some View {
        HStack {
            Image(systemName: "heart.text.square")
            Text("Health Cards")
        }
        .font(.subheadline)
        .onAppear {
            viewModel.setup(context: context)
        }
        if viewModel.userSessions.isEmpty {
            NavigationLink {
                HealthFormView()
            } label: {
                AddHealthCardView()
            }
        } else {
            HStack {
                HealthCardView(userSession: viewModel.userSessions.first!, dateFormatter: { date in
                    return date?.formatted(relativeTo: Date()) ?? ""
                })
                    .frame(width: 300)
                VStack {
                    NavigationLink {
                        HealthFormView()
                    } label: {
                        Image(systemName: "plus.circle")
                    }
                    .padding()
                    NavigationLink {
                        HistoricalHealthCardsView(viewModel: viewModel)
                    } label: {
                        Image(systemName: "clock.arrow.circlepath")
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
