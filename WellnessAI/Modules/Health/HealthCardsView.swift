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
            if !viewModel.userSessions.isEmpty {
                Spacer()
                NavigationLink {
                    HistoricalHealthCardsView(viewModel: viewModel)
                } label: {
                    Image(systemName: "clock.arrow.circlepath")
                }
            }
        }
        .font(.subheadline)
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                if let userSession = viewModel.userSessions.first {
                    HealthCardView(userSession: userSession, dateFormatter: { $0?.formatted(relativeTo: Date()) ?? "" })
                        .frame(width: 300)
                }
                NavigationLink {
                    HealthFormView()
                } label: {
                    AddHealthCardView()
                }
                .frame(width: 300)
                .frame(maxHeight: .infinity)
            }
            .fixedSize(horizontal: false, vertical: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
        }
        .padding(EdgeInsets(
            top: 8, leading: 0, bottom: 8, trailing: 0
        ))
        .onAppear {
            viewModel.setup(context: context)
        }
    }
}
