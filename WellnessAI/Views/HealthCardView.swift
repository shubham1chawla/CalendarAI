//
//  SummaryCardView.swift
//  WellnessAI
//
//  Created by Shubham Chawla on 12/17/23.
//

import SwiftUI

struct HealthCardView: View {
    
    let userSession: UserSession
    let intensities: [Int:String]
    let dateFormatter: (Date?) -> String
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: "clock")
                Text(dateFormatter(userSession.timestamp))
            }
            .font(.caption)
            .padding()
            VStack(alignment: .center) {
                HStack(spacing: 36) {
                    VStack {
                        HStack {
                            Image(systemName: "heart")
                            Text("\(userSession.userMeasurement?.heartRate ?? 0, specifier: "%.2f")")
                        }
                        .font(.headline)
                        Text("Heart Rate")
                            .font(.caption)
                    }
                    VStack {
                        HStack {
                            Image(systemName: "lungs")
                            Text("\(userSession.userMeasurement?.respRate ?? 0, specifier: "%.2f")")
                        }
                        .font(.headline)
                        Text("Respiratory Rate")
                            .font(.caption)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            VStack(spacing: 8) {
                let userSymptoms = userSession.userSymptoms?.allObjects as! [UserSymptom]
                ForEach(userSymptoms) { userSymptom in
                    HStack {
                        Image(systemName: "staroflife")
                        Text(userSymptom.symptom!.name!)
                        Spacer()
                        Text("\(intensities[Int(userSymptom.intensity)]!) (\(userSymptom.intensity))")
                    }
                    .font(.subheadline)
                }
            }
            .padding()
        }
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 4))
    }
}
