//
//  HealthView.swift
//  CalendarAI
//
//  Created by Shubham Chawla on 11/24/23.
//

import SwiftUI

struct HealthView: View {
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "id", ascending: true)]) var symptoms: FetchedResults<Symptom>
    @EnvironmentObject var dataService: DataService
    
    @State private var symptomIndex: Int = 1
    @State private var intensity: Int = 1
    
    var body: some View {
        NavigationView {
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
                        ForEach(Array(symptoms.enumerated()), id: \.element) { index, symptom in
                            Text(symptom.name!).tag(index)
                        }
                    } label: {
                        Image(systemName: "staroflife")
                        Text("Symptom")
                    }
                    .pickerStyle(.navigationLink)
                    Picker(selection: $intensity) {
                        ForEach(Array(dataService.intensities.keys).sorted(), id: \.self) { key in
                            Text("\(key) - \(dataService.intensities[key]!)").tag(key)
                        }
                    } label: {
                        Image(systemName: "exclamationmark.circle")
                        Text("Severity")
                    }
                    .pickerStyle(.navigationLink)
                }
                Button {
                    dataService.saveUserSymptom(symptom: symptoms[symptomIndex], intensity: intensity)
                } label: {
                    Text("Save")
                }
            }
            .navigationTitle("Health")
            .toolbar {
                HStack {
                    NavigationLink {
                        HistoryView()
                    } label: {
                        Image(systemName: "clock.arrow.circlepath")
                    }
                }
            }
        }
    }
}
