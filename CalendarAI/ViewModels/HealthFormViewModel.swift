//
//  HealthFormViewModel.swift
//  CalendarAI
//
//  Created by Shubham Chawla on 12/17/23.
//

import Foundation

extension HealthFormView {
    @MainActor class ViewModel: ObservableObject {
        
        @Published var symptoms: [Symptom] = []
        @Published var intensities: [Int:String] = [:]
        
        @Published var heartRate: Double = 0
        @Published var respRate: Double = 0
        
        @Published var showRespRateTip: Bool = false
        @Published var isMeasuringRespRate: Bool = false
        
        @Published var selectedSymptomIndex: Int = 0
        @Published var selectedIntensityValue: Int = 1
        @Published var selectedSymptoms: [SelectedSymptom] = []
        
        init() {
            self.symptoms = decodeJson(getSymptomsJsonPath())
            let intensities: [Intensity] = decodeJson(getIntensitiesJsonPath())
            for intensity in intensities {
                self.intensities[intensity.value] = intensity.label
            }
        }
        
        func handleRespRateMeasurement() -> Void {
            
        }
        
        func addStaggedSymptom() -> Void {
            selectedSymptoms.removeAll { selected in
                return selected.index == selectedSymptomIndex
            }
            selectedSymptoms.append(SelectedSymptom(index: selectedSymptomIndex, intensity: selectedIntensityValue))
        }
        
        func removeSelectedSymptoms(_ indexes: IndexSet) -> Void {
            selectedSymptoms.remove(atOffsets: indexes)
        }
        
        func persistHealthInformation() -> Void {
            
        }
        
        private func getSymptomsJsonPath() -> URL {
            return getJsonPath("symptoms")
        }
        
        private func getIntensitiesJsonPath() -> URL {
            return getJsonPath("intensities")
        }
        
        private func getJsonPath(_ resource: String) -> URL {
            guard let path = Bundle.main.path(forResource: resource, ofType: "json") else {
                fatalError("Couldn't load \(resource).json")
            }
            return URL(filePath: path)
        }
        
        private func decodeJson<T: Decodable>(_ url: URL) -> [T] {
            do {
                let data = try Data(contentsOf: url)
                return try JSONDecoder().decode([T].self, from: data)
            } catch {
                fatalError(error.localizedDescription)
            }
        }
        
    }
}
