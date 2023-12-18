//
//  HealthModels.swift
//  CalendarAI
//
//  Created by Shubham Chawla on 12/17/23.
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

struct SelectedSymptom {
    var index: Int
    var intensity: Int
}
