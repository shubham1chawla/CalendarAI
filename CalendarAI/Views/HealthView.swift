//
//  HealthView.swift
//  CalendarAI
//
//  Created by Shubham Chawla on 11/24/23.
//

import SwiftUI

struct StaggedSymptom {
    var symptomIndex: Int
    var intensity: Int
}

struct HealthView: View {
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "id", ascending: true)]) var symptoms: FetchedResults<Symptom>
    @EnvironmentObject var dataService: DataService
    @EnvironmentObject var measurementService: MeasurementService
    
    @State private var symptomIndex: Int = 0
    @State private var intensity: Int = 1
    @State private var heartRate: Double = 0
    @State private var respRate: Double = 0
    @State private var staggedSymptoms: [StaggedSymptom] = []
    
    @State private var isMeasuringRespRate = false
    @State private var showRespRateTip = false
    @State private var showSaveAlert = false
    
    var body: some View {
        NavigationView {
            Form {
                Section("Measurements") {
                    NavigationLink {
                        CameraView(heartRate: $heartRate)
                    } label: {
                        HStack {
                            Image(systemName: "heart")
                            Text("Heart Rate: \(heartRate, specifier: "%.2f") bpm")
                        }
                        .foregroundColor(.accentColor)
                    }
                    Button {
                        showRespRateTip.toggle()
                    } label: {
                        HStack {
                            if isMeasuringRespRate {
                                ProgressView()
                                Text(" Measuring Respiratory Rate")
                            }
                            else {
                                Image(systemName: "lungs")
                                Text("Respiratory Rate: \(respRate, specifier: "%.2f") bpm")
                            }
                        }
                    }
                    .disabled(isMeasuringRespRate)
                    .alert("Respiratory Rate Measurement Instructions", isPresented: $showRespRateTip) {
                        Button("Cancel", role: .cancel) { }
                        Button("Start Measuring", role: .none) {
                            handleRespRateMeasurement()
                        }
                    } message: {
                        Text("Please lay down facing up. Place the device flat between your chest and stomach. Press the \"Start Measuring\" button and continue to take deep breaths.")
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
                    Button {
                        staggedSymptoms.removeAll { stagged in
                            return stagged.symptomIndex == symptomIndex
                        }
                        staggedSymptoms.append(StaggedSymptom(symptomIndex: symptomIndex, intensity: intensity))
                    } label: {
                        HStack {
                            Image(systemName: "plus")
                            Text("Add Symptom")
                        }
                    }
                }
                Section("Recorded Symptoms") {
                    List {
                        ForEach(staggedSymptoms, id:\.symptomIndex) { stagged in
                            HStack {
                                Image(systemName: "staroflife")
                                Text("\(symptoms[stagged.symptomIndex].name!) - \(dataService.intensities[stagged.intensity]!) (\(stagged.intensity))")
                            }
                        }
                        .onDelete { indexes in
                            staggedSymptoms.remove(atOffsets: indexes)
                        }
                    }
                }
            }
            .navigationTitle("Health")
            .toolbar {
                HStack(alignment: .bottom) {
                    NavigationLink {
                        HistoryView()
                    } label: {
                        Image(systemName: "clock.arrow.circlepath")
                    }
                    Button {
                        dataService.saveSensorRecord(heartRate: heartRate, respRate: respRate)
                        for stagged in staggedSymptoms {
                            dataService.saveUserSymptom(symptom: symptoms[stagged.symptomIndex], intensity: stagged.intensity)
                        }
                        showSaveAlert.toggle()
                    } label: {
                        Image(systemName: "arrow.down.circle")
                    }
                    .alert("Your health measurements have been recorded.", isPresented: $showSaveAlert) {
                        Button("Dismiss", role: .cancel) { }
                    }
                }
            }
        }
    }
    
    private func handleRespRateMeasurement() -> Void {
        isMeasuringRespRate.toggle()
        measurementService.calculateRespRate { result in
            switch result {
            case .success(let respRate):
                self.respRate = respRate
            case .failure(let error):
                print(error.localizedDescription)
            }
            isMeasuringRespRate.toggle()
        }
    }
    
}
