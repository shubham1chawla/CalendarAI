//
//  HealthFormView.swift
//  CalendarAI
//
//  Created by Shubham Chawla on 12/17/23.
//

import SwiftUI

struct HealthFormView: View {
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
                    .foregroundColor(.accentColor)
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
                .disabled(viewModel.isMeasuringRespRate)
                .alert("Respiratory Rate Measurement Instructions", isPresented: $viewModel.showRespRateTip) {
                    Button("Cancel", role: .cancel) { }
                    Button("Start Measuring", role: .none) {
                        viewModel.handleRespRateMeasurement()
                    }
                } message: {
                    Text("Please lay down facing up. Place the device flat between your chest and stomach. Press the \"Start Measuring\" button and continue to take deep breaths.")
                }
            }
            
            Section("Symptoms") {
                Picker(selection: $viewModel.selectedSymptomIndex) {
                    ForEach(Array(viewModel.symptoms.enumerated()), id:\.offset) { index, symptom in
                        Text(symptom.name).tag(index)
                    }
                } label: {
                    Image(systemName: "staroflife")
                    Text("Symptom")
                }
                .pickerStyle(.navigationLink)
                Picker(selection: $viewModel.selectedIntensityValue) {
                    ForEach(Array(viewModel.intensities.keys).sorted(), id:\.self) { key in
                        Text("\(key) - \(viewModel.intensities[key]!)").tag(key)
                    }
                } label: {
                    Image(systemName: "exclamationmark.circle")
                    Text("Intensity")
                }
                .pickerStyle(.navigationLink)
                Button {
                    viewModel.addStaggedSymptom()
                } label: {
                    HStack {
                        Image(systemName: "plus")
                        Text("Add Symptom")
                    }
                }
            }
            
            if !viewModel.selectedSymptoms.isEmpty {
                Section("Recorded Symptoms") {
                    List {
                        ForEach(viewModel.selectedSymptoms, id:\.index) { selected in
                            HStack {
                                Image(systemName: "staroflife")
                                Text(viewModel.symptoms[selected.index].name)
                                Spacer()
                                Text("\(viewModel.intensities[selected.intensity]!) (\(selected.intensity))")
                            }
                        }
                        .onDelete { indexes in
                            viewModel.removeSelectedSymptoms(indexes)
                        }
                    }
                }
            }
            
        }
        .navigationTitle("Health")
        .toolbar {
            HStack {
                Button {
                    viewModel.persistHealthInformation()
                } label: {
                    Image(systemName: "square.and.arrow.down")
                }
            }
        }
    }
}

#Preview {
    HealthFormView()
}
