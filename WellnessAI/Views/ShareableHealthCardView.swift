//
//  ShareableHealthCardView.swift
//  WellnessAI
//
//  Created by Shubham Chawla on 12/20/23.
//

import SwiftUI

struct ShareableHealthCardView: View {
    
    let userSession: UserSession
    let intensities: [Int:String]
    
    @State private var image: Image?
    
    var card: some View {
        HealthCardView(userSession: userSession, intensities: intensities)
            .padding()
    }
    
    var body: some View {
        ScrollView(.vertical) {
            card.onAppear {
                if image == nil {
                    image = Image(uiImage: card.snapshot())
                }
            }
        }
        .navigationTitle("Health Card")
        .toolbar {
            if image != nil {
                ShareLink(item: image!, preview: SharePreview("Health Card", image: image!)) {
                    Label("", systemImage: "square.and.arrow.up")
                }
            }
        }
    }
}
