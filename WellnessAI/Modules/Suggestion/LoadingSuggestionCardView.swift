//
//  LoadingSuggestionCardView.swift
//  WellnessAI
//
//  Created by Shubham Chawla on 12/28/23.
//

import SwiftUI

struct LoadingSuggestionCardView: View {
    var body: some View {
        VStack {
            ProgressView {
                Text("Loading Suggestions")
                    .font(.headline)
                    .padding(EdgeInsets(
                        top: 4, leading: 16, bottom: 24, trailing: 16
                    ))
            }
            .controlSize(.extraLarge)
            .padding(EdgeInsets(
                top: 24, leading: 16, bottom: 4, trailing: 16
            ))
        }
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 4))
    }
}

#Preview {
    LoadingSuggestionCardView()
}
