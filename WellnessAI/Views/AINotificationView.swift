//
//  AINotificationView.swift
//  WellnessAI
//
//  Created by Shubham Chawla on 12/16/23.
//

import SwiftUI

struct AINotificationView: View {
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: "tag")
                Text("Calendar")
            }
            .font(.caption)
            .padding(EdgeInsets(
                top: 24, leading: 16, bottom: 8, trailing: 16
            ))
            HStack {
                Text("This is a sample text representing the notification's content.")
            }
            .font(.headline)
            .padding(EdgeInsets(
                top: 8, leading: 16, bottom: 24, trailing: 16
            ))
        }
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 4))
    }
}

#Preview {
    AINotificationView()
}
