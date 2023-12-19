//
//  JsonUtils.swift
//  WellnessAI
//
//  Created by Shubham Chawla on 12/19/23.
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

func decodeJson<T: Decodable>(forResource: String) -> [T] {
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
