//
//  SummaryCardView.swift
//  WellnessAI
//
//  Created by Shubham Chawla on 12/17/23.
//

import SwiftUI

struct HealthCardView: View {
    
    @ObservedObject var viewModel: HealthCardsView.ViewModel
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "clock")
                Text(viewModel.userSessions.first!.timestamp!.formatted())
                Spacer()
            }
            .font(.caption)
            .padding(EdgeInsets(
                top: 24, leading: 16, bottom: 8, trailing: 16
            ))
            HStack {
                Spacer()
                VStack {
                    HStack {
                        Image(systemName: "heart")
                        Text("\(viewModel.userSessions.first!.userMeasurement?.heartRate ?? 0, specifier: "%.2f")")
                    }
                        .font(.title2)
                }
                Spacer()
                VStack {
                    HStack {
                        Image(systemName: "lungs")
                        Text("\(viewModel.userSessions.first!.userMeasurement?.respRate ?? 0, specifier: "%.2f")")
                    }
                        .font(.title2)
                }
                Spacer()
            }
            .padding(EdgeInsets(
                top: 8, leading: 16, bottom: 8, trailing: 16
            ))
            VStack(alignment: .leading) {
                let userSymptoms = viewModel.userSessions.first!.userSymptoms?.allObjects as! [UserSymptom]
                ForEach(userSymptoms) { userSymptom in
                    HStack {
                        Image(systemName: "staroflife")
                        Text(userSymptom.symptom!.name!)
                        Spacer()
                        Text("\(viewModel.intensities[Int(userSymptom.intensity)]!) (\(userSymptom.intensity))")
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
