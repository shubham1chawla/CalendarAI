//
//  AddHealthCardView.swift
//  WellnessAI
//
//  Created by Shubham Chawla on 12/19/23.
//

import SwiftUI

struct AddHealthCardView: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "plus.circle")
                .font(.largeTitle)
            Text("Add Health Information")
        }
        .fontWeight(.bold)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(UIConstants.BACKGROUND_MATERIAL)
        .clipShape(RoundedRectangle(cornerRadius: UIConstants.CORNER_RADIUS))
    }
}

#Preview {
    AddHealthCardView()
}
