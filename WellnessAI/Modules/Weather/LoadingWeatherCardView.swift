//
//  LoadingWeatherCardView.swift
//  WellnessAI
//
//  Created by Shubham Chawla on 12/22/23.
//

import SwiftUI

struct LoadingWeatherCardView: View {
    var body: some View {
        VStack {
            ProgressView {
                Text("Loading Weather Information")
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
    LoadingWeatherCardView()
}
