//
//  HealthCardsView.swift
//  WellnessAI
//
//  Created by Shubham Chawla on 12/17/23.
//

import SwiftUI

struct HealthCardsView: View {
    var body: some View {
        HStack {
            Image(systemName: "heart.text.square")
            Text("Health Cards")
        }
        .font(.subheadline)
        if true {
            NavigationLink {
                HealthFormView()
            } label: {
                AddHealthCardView()
            }
        } else {
            HStack {
                HealthCardView()
                    .frame(width: 300)
                VStack {
                    NavigationLink {
                        HealthFormView()
                    } label: {
                        Image(systemName: "plus.circle")
                    }
                    .padding()
                    NavigationLink {
                        Text("History")
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

#Preview {
    HealthCardsView()
}
