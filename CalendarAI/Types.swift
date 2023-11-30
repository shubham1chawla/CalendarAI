//
//  Types.swift
//  CalendarAI
//
//  Created by Himanshu Sharma on 11/29/23.
//

import Foundation

public struct DecodableSymptom: Decodable {
    var id: Int
    var name: String
}

public struct DecodableIntensity: Decodable {
    var label: String
    var value: Int
}
