//
//  HealthView.swift
//  CalendarAI
//
//  Created by Shubham Chawla on 11/24/23.
//

import SwiftUI

struct HealthView: View {
    
    @State private var symptomIndex: Int = 0
    @State private var intensity: Int = 1
    
    private var symptoms = [
        1:"Symptom 1",
        2:"Symptom 2",
        3:"Symptom 3",
    ]
    
    private var intensities = [
        1:"Intensity 1",
        2:"Intensity 2",
        3:"Intensity 3",
    ]
    
    var body: some View {
        Form {
            Section("Measurements") {
                NavigationLink {
                    
                } label: {
                    HStack {
                        Image(systemName: "heart")
                        Text("Heart Rate")
                    }
                }
                NavigationLink {
                    
                } label: {
                    HStack {
                        Image(systemName: "lungs")
                        Text("Respiratory Rate")
                    }
                }
            }
            Section("Symptoms") {
                Picker(selection: $symptomIndex) {
                    ForEach(Array(intensities.keys).sorted(), id: \.self) { key in
                        Text(symptoms[key]!).tag(key)
                    }
                } label: {
                    Image(systemName: "staroflife")
                    Text("Symptom")
                }
                .pickerStyle(.navigationLink)
                Picker(selection: $intensity) {
                    ForEach(Array(intensities.keys).sorted(), id: \.self) { key in
                        Text("\(key) - \(intensities[key]!)").tag(key)
                    }
                } label: {
                    Image(systemName: "exclamationmark.circle")
                    Text("Severity")
                }
                .pickerStyle(.navigationLink)
            }
        }
    }
}

#Preview {
    HealthView()
}
