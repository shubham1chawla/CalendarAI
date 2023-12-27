//
//  Errors.swift
//  WellnessAI
//
//  Created by Shubham Chawla on 12/27/23.
//

import Foundation

enum AppError: LocalizedError {
    case googleNearbyPlacesAPIKeyMissing
    case openWeatherAPIKeyMissing
    
    var errorDescription: String? {
        switch self {
        case .googleNearbyPlacesAPIKeyMissing:
            return "Google Nearby Places API not set in the Settings!"
        case .openWeatherAPIKeyMissing:
            return "Open Weather API not set in the Settings!"
        }
    }
}
