//
//  SummaryCardView.swift
//  WellnessAI
//
//  Created by Shubham Chawla on 12/17/23.
//

import SwiftUI

struct HealthCardView: View {
    
    let userSession: UserSession
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
                            if let heartRate = userSession.userMeasurement?.heartRate {
                                Text("\(heartRate, specifier: "%.2f")")
                            } else {
                                Text("--")
                            }
                        }
                        .font(.headline)
                        Text("Heart Rate")
                            .font(.caption)
                    }
                    VStack {
                        HStack {
                            Image(systemName: "lungs")
                            if let respRate = userSession.userMeasurement?.respRate {
                                Text("\(respRate, specifier: "%.2f")")
                            } else {
                                Text("--")
                            }
                        }
                        .font(.headline)
                        Text("Respiratory Rate")
                            .font(.caption)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "list.bullet.clipboard")
                    Text("Recorded Symptoms")
                }
                .fontWeight(.bold)
                let userSymptoms = userSession.userSymptoms?.allObjects as! [UserSymptom]
                if userSymptoms.isEmpty {
                    Text("No Symptoms recorded!")
                } else {
                    ForEach(userSymptoms) { userSymptom in
                        HStack {
                            Image(systemName: "staroflife")
                            Text(userSymptom.symptom!.name!)
                            Spacer()
                            Text("\(userSymptom.intensityLabel!) (\(Int(userSymptom.intensityValue)))")
                        }
                        
                    }
                }
            }
            .font(.subheadline)
            .padding()
        }
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 4))
    }
}
