//
//  GoogleNearbyPlacesModel.swift
//  WellnessAI
//
//  Created by Shubham Chawla on 12/27/23.
//

import Foundation
import CoreLocation

enum GoogleNearbyPlaceType: String {
    case hospital
    case shopping_mall
}

struct GoogleNearbyPlacesRequest {
    let location: CLLocation
    let type: GoogleNearbyPlaceType
}

struct GoogleNearbyPlacesResponse: Decodable {
    let status: String
    let results: [GoogleNearbyPlace]
}

struct GoogleNearbyPlace: Decodable {
    let name: String
    let rating: Double?
    let userRatingsTotal: Int?
    let types: [String]
}

extension GoogleNearbyPlacesRequest {
    
    func fetch() async throws -> [GoogleNearbyPlace] {
        let apiKey = UserDefaults.standard.string(forKey: Keys.OPEN_WEATHER_API_KEY_IDENTIFIER)
        guard !(apiKey ?? "").isEmpty else { throw AppError.googleNearbyPlacesAPIKeyMissing }
        
        var components = URLComponents(string: "https://maps.googleapis.com/maps/api/place/nearbysearch/json")!
        components.queryItems = [
            URLQueryItem(name: "location", value: "\(location.coordinate.latitude)/\(location.coordinate.longitude)"),
            URLQueryItem(name: "radius", value: "\(APIConstants.GOOGLE_NEARBY_PLACES_RADIUS)"),
            URLQueryItem(name: "type", value: type.rawValue),
            URLQueryItem(name: "key", value: apiKey)
        ]
        
        let request = URLRequest(url: components.url!)
        let (data, urlResponse) = try await URLSession.shared.data(for: request)
        
        guard
            let httpResponse = urlResponse as? HTTPURLResponse,
            httpResponse.statusCode >= 200 && httpResponse.statusCode < 300
        else {
            throw URLError(.badServerResponse)
        }
        
        let apiResponse = try JSONDecoder().decode(GoogleNearbyPlacesResponse.self, from: data)
        guard apiResponse.status == "OK" else { throw URLError(.badServerResponse) }
        return apiResponse.results
    }
    
}
