//
//  SummaryCardView.swift
//  CalendarAI
//
//  Created by Shubham Chawla on 12/17/23.
//

import SwiftUI

struct HealthCardView: View {
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "clock")
                Text(Date().formatted())
                Spacer()
            }
            .font(.caption)
            .padding(EdgeInsets(
                top: 24, leading: 16, bottom: 8, trailing: 16
            ))
            HStack {
                Spacer()
                HStack {
                    Image(systemName: "heart")
                    Text("72.22")
                }
                Spacer()
                HStack {
                    Image(systemName: "lungs")
                    Text("14.42")
                }
                Spacer()
            }
            .font(.headline)
            .padding(EdgeInsets(
                top: 8, leading: 16, bottom: 8, trailing: 16
            ))
            VStack(alignment: .leading) {
                ForEach(1..<4) { num in
                    HStack {
                        Image(systemName: "staroflife")
                        Text("Symptom \(num)")
                        Spacer()
                        Text("Medium (3)")
                    }
                    .font(.subheadline)
                }
            }
            .padding(EdgeInsets(
                top: 8, leading: 16, bottom: 24, trailing: 16
            ))
        }
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 4))
    }
}

#Preview {
    HealthCardView()
}
