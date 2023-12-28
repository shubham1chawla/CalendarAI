//
//  ViewHistoricalSuggestionsCardView.swift
//  WellnessAI
//
//  Created by Shubham Chawla on 12/28/23.
//

import SwiftUI

struct ViewHistoricalSuggestionsCardView: View {
    var body: some View {
        VStack {
            Image(systemName: "clock.arrow.circlepath")
                .font(.title)
                .padding(EdgeInsets(
                    top: 24, leading: 16, bottom: 4, trailing: 16
                ))
            Text("View Historical Suggestions")
                .font(.headline)
                .padding(EdgeInsets(
                    top: 4, leading: 16, bottom: 24, trailing: 16
                ))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 4))
    }
}

#Preview {
    ViewHistoricalSuggestionsCardView()
}
