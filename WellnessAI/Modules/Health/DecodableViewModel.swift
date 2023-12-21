//
//  DecodableViewModel.swift
//  WellnessAI
//
//  Created by Shubham Chawla on 12/22/23.
//

import Foundation

struct DecodableSymptom: Decodable, Identifiable {
    let id: Int16
    let name: String
}

struct DecodableIntensity: Decodable {
    let label: String
    let value: Int
}

class DecodableViewModel: ObservableObject {
    
    @Published private(set) var decodableSymptoms: [DecodableSymptom] = []
    @Published private(set) var decodableIntensities: [DecodableIntensity] = []
    @Published private(set) var intensities: [Int:String] = [:]
    
    init() {
        decodableSymptoms = DecodableViewModel.decodeJson(forResource: "symptoms")
        decodableIntensities = DecodableViewModel.decodeJson(forResource: "intensities")
        
        for decodableIntensity in decodableIntensities {
            intensities[decodableIntensity.value] = decodableIntensity.label
        }
    }
    
    private static func decodeJson<T: Decodable>(forResource: String) -> [T] {
        guard let path = Bundle.main.path(forResource: forResource, ofType: "json") else {
            fatalError("Unable to load \(forResource).json!")
        }
        do {
            let data = try Data(contentsOf: URL(filePath: path))
            return try JSONDecoder().decode([T].self, from: data)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
}
