//
//  AddHealthCardView.swift
//  WellnessAI
//
//  Created by Shubham Chawla on 12/19/23.
//

import SwiftUI

struct AddHealthCardView: View {
    var body: some View {
        VStack {
            Image(systemName: "plus.circle")
                .font(.largeTitle)
                .padding(EdgeInsets(
                    top: 24, leading: 16, bottom: 4, trailing: 16
                ))
            Text("Add Health Information")
                .font(.subheadline)
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
    AddHealthCardView()
}
