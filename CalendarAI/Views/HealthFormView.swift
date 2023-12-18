//
//  HealthFormView.swift
//  CalendarAI
//
//  Created by Shubham Chawla on 12/17/23.
//

import SwiftUI

struct HealthFormView: View {
    
    @Environment(\.managedObjectContext) var moc
    @StateObject private var viewModel = ViewModel()
    
    var body: some View {
        Form {
            Section("Measurements") {
                NavigationLink {
                    Text("123")
                } label: {
                    HStack {
                        Image(systemName: "heart")
                        Text("Heart Rate: \(viewModel.heartRate, specifier: "%.2f") bpm")
                    }
                }
                Button {
                    viewModel.showRespRateTip.toggle()
                } label: {
                    HStack {
                        if viewModel.isMeasuringRespRate {
                            ProgressView()
                            Text(" Measuring Respiratory Rate")
                        }
                        else {
                            Image(systemName: "lungs")
                            Text("Respiratory Rate: \(viewModel.respRate, specifier: "%.2f") bpm")
                        }
                    }
                }
                .buttonStyle(.plain)
                .disabled(viewModel.isMeasuringRespRate)
                .alert("Respiratory Rate Measurement Instructions", isPresented: $viewModel.showRespRateTip) {
                    Button("Cancel", role: .cancel) { }
                    Button("Start Measuring", role: .none) {
                        
                    }
                } message: {
                    Text("Please lay down facing up. Place the device flat between your chest and stomach. Press the \"Start Measuring\" button and continue to take deep breaths.")
                }
            }
            Section("Symptoms") {
                Picker(selection: $viewModel.selectedSymptomIndex) {
                    ForEach(Array(viewModel.symptoms.enumerated()), id:\.offset) { index, symptom in
                        Text(symptom.name!).tag(index)
                    }
                } label: {
                    Image(systemName: "staroflife")
                    Text("Symptom")
                }
                .pickerStyle(.navigationLink)
                Picker(selection: $viewModel.selectedIntensityValue) {
                    ForEach(Array(viewModel.intensities.keys).sorted(), id:\.self) { key in
                        Text("\(viewModel.intensities[key]!) (\(key))").tag(key)
                    }
                } label: {
                    Image(systemName: "exclamationmark.circle")
                    Text("Intensity")
                }
                .pickerStyle(.navigationLink)
                Button {
                    viewModel.addUserSymptom()
                } label: {
                    HStack {
                        Image(systemName: "plus")
                        Text("Add Symptom")
                    }
                }
            }
            if !viewModel.userSymptoms.isEmpty {
                Section("Recorded Symptoms") {
                    List {
                        ForEach(viewModel.userSymptoms, id:\.self) { userSymptom in
                            HStack {
                                Image(systemName: "staroflife")
                                Text(userSymptom.symptom?.name ?? "Unknown")
                                Spacer()
                                Text("\(viewModel.intensities[Int(userSymptom.intensity)]!) (\(userSymptom.intensity))")
                            }
                        }
                        .onDelete { indexes in
                            viewModel.removeUserSymptoms(atOffsets: indexes)
                        }
                    }
                }
            }
            
        }
        .navigationTitle("Health")
        .toolbar {
            HStack {
                Button {
                    
                } label: {
                    Image(systemName: "square.and.arrow.down")
                }
            }
        }
        .onAppear {
            viewModel.setNSManagedObjectContext(moc)
        }
    }
}

#Preview {
    HealthFormView()
}