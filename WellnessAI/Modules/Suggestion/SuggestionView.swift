//
//  SuggestionView.swift
//  WellnessAI
//
//  Created by Shubham Chawla on 12/16/23.
//

import SwiftUI

struct SuggestionView: View {
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: "tag")
                Text("Calendar")
            }
            .font(.caption)
            .padding()
            HStack {
                Text("This is a sample text representing the notification's content.")
            }
            .font(.headline)
            .padding()
        }
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 4))
    }
}

#Preview {
    SuggestionView()
}
