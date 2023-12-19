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
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: "clock")
                Text(userSession.timestamp!.asTimeAgoFormatted())
            }
            .font(.caption)
            .padding(EdgeInsets(
                top: 24, leading: 16, bottom: 8, trailing: 16
            ))
            HStack(alignment: .center) {
                Spacer()
                HStack {
                    Image(systemName: "heart")
                    Text("\(userSession.userMeasurement?.heartRate ?? 0, specifier: "%.2f")")
                }
                Spacer()
                HStack {
                    Image(systemName: "lungs")
                    Text("\(userSession.userMeasurement?.respRate ?? 0, specifier: "%.2f")")
                }
                Spacer()
            }
            .font(.title2)
            .padding(EdgeInsets(
                top: 8, leading: 16, bottom: 8, trailing: 16
            ))
            VStack(alignment: .leading, spacing: 4) {
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
            .padding(EdgeInsets(
                top: 8, leading: 16, bottom: 24, trailing: 16
            ))
        }
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 4))
    }
}
