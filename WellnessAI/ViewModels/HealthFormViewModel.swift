//
//  HealthFormViewModel.swift
//  WellnessAI
//
//  Created by Shubham Chawla on 12/17/23.
//

import Foundation
import CoreData

extension HealthFormView {
    @MainActor class ViewModel: ObservableObject {
        
        private var context: NSManagedObjectContext?
        
        @Published private(set) var symptoms: [Symptom] = []
        @Published private(set) var intensities: [Int:String] = [:]
        @Published private(set) var userSymptoms: [UserSymptom] = []
        
        @Published var heartRate: Double = 0
        @Published var respRate: Double = 0
        
        @Published var showRespRateTip: Bool = false
        @Published var isMeasuringRespRate: Bool = false
        
        @Published var selectedSymptomIndex: Int = 0
        @Published var selectedIntensityValue: Int = 1
        
        func setNSManagedObjectContext(_ context: NSManagedObjectContext? = nil) {
            self.context = context
            
            // Setting up symptoms & intensities from JSON file
            loadDefaultSymptoms()
            loadDefaultIntensities()
            
            // Loading symptoms from database
            setSymptoms()
        }
        
        func addUserSymptom() -> Void {
            guard let context = context else { return }
            userSymptoms.removeAll { userSymptom in
                return userSymptom.symptom == symptoms[selectedSymptomIndex]
            }
            let userSymptom = UserSymptom(context: context)
            userSymptom.symptom = symptoms[selectedSymptomIndex]
            userSymptom.intensity = Int16(selectedIntensityValue)
            userSymptoms.append(userSymptom)
        }
        
        func removeUserSymptoms(atOffsets: IndexSet) -> Void {
            userSymptoms.remove(atOffsets: atOffsets)
        }
        
        private func setSymptoms() -> Void {
            guard let context = context else { return }
            let request = Symptom.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
            var symptoms: [Symptom] = []
            for symptom in try! context.fetch(request) {
                symptoms.append(symptom)
            }
            self.symptoms = symptoms
        }
        
        private func loadDefaultSymptoms() -> Void {
            guard let context = context else { return }
            let decodableSymptoms: [DecodableSymptom] = decodeJson(forResource: "symptoms")
            decodableSymptoms.forEach { decodableSymptom in
                
                // Checking if the symptom exists in database
                let request = Symptom.fetchRequest()
                request.predicate = NSPredicate(format: "id == %i", decodableSymptom.id)
                let symptoms = try? context.fetch(request)
        
                if (symptoms ?? []).isEmpty {
                    let symptom = Symptom(context: context)
                    symptom.id = decodableSymptom.id
                    symptom.name = decodableSymptom.name
                    try? context.save()
                }
            }
        }
        
        private func loadDefaultIntensities() -> Void {
            let decodableIntensities: [DecodableIntensity] = decodeJson(forResource: "intensities")
            decodableIntensities.forEach { decodableIntensity in
                intensities[decodableIntensity.value] = decodableIntensity.label
            }
        }
        
        private func decodeJson<T: Decodable>(forResource: String) -> [T] {
            guard let path = Bundle.main.path(forResource: forResource, ofType: "json") else {
                fatalError("Unable to load default symptoms!")
            }
            do {
                let data = try Data(contentsOf: URL(filePath: path))
                return try JSONDecoder().decode([T].self, from: data)
            } catch {
                fatalError(error.localizedDescription)
            }
        }
        
    }
}
