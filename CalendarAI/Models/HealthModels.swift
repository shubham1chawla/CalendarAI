//
//  HealthModels.swift
//  CalendarAI
//
//  Created by Shubham Chawla on 12/17/23.
//

import Foundation

struct Symptom: Decodable, Identifiable {
    let id: Int
    let name: String
}

struct Intensity: Decodable {
    let label: String
    let value: Int
}

struct SelectedSymptom {
    var index: Int
    var intensity: Int
}
