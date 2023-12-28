//
//  ErrorSuggestionCardView.swift
//  WellnessAI
//
//  Created by Shubham Chawla on 12/27/23.
//

import SwiftUI

struct ErrorSuggestionCardView: View {
    var errorMessage: String?
    var body: some View {
        VStack {
            Image(systemName: "exclamationmark.icloud")
                .font(.title)
                .padding(EdgeInsets(
                    top: 24, leading: 16, bottom: 4, trailing: 16
                ))
            VStack(alignment: .leading) {
                Text("Something went wrong!")
                    .font(.headline)
                Text(errorMessage ?? "Unable to present suggestions")
                    .font(.caption)
            }
            .padding(EdgeInsets(
                top: 4, leading: 16, bottom: 24, trailing: 16
            ))
        }
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 4))
    }
}

#Preview {
    ErrorSuggestionCardView()
}
