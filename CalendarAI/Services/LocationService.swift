//
//  LocationService.swift
//  CalendarAI
//
//  Created by Vedant Pople on 11/28/23.
//

import Foundation
import CoreLocation
import MapKit

struct GoogleNearbyPlacesResponse: Decodable {
    var results: [GoogleNearbyPlace]
}

struct GoogleNearbyPlace: Decodable {
    var name: String
    var rating: Double?
    var user_ratings_total: Int?
    var types: [String]
}

enum NetworkError: Error {
    case invalidURL
    case noData
    case invalidResponse
}

class LocationService: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    private let locationManager = CLLocationManager()
    private var didUpdateLocationsListeners: [() -> Void] = []
    @Published var coordinate: CLLocationCoordinate2D?
    
    func requestLocationAccess() -> Void {
        locationManager.requestWhenInUseAuthorization()
        DispatchQueue.global(qos: .background).async {
            if CLLocationManager.locationServicesEnabled() {
                self.locationManager.delegate = self
                self.locationManager.startUpdatingLocation()
            }
        }
    }
    
    func registerListener(_ listener: @escaping () -> Void) -> Void {
        didUpdateLocationsListeners.append(listener)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        coordinate = manager.location?.coordinate
        for listener in didUpdateLocationsListeners {
            listener()
        }
    }
    
    private func getAPIKey() -> String {
        let key = UserDefaults.standard.string(forKey: Keys.GOOGLE_API_KEY_IDENTIFIER)
        if (key == nil || key!.isEmpty) {
            fatalError("Please provide a valid Google API key in Settings!")
        }
        return key!
    }
    
    func getNearbyPlaces(placeType: String, completion: @escaping (Result<GoogleNearbyPlacesResponse, Error>) -> Void) {
        getNearbyPlaces(coordinate: coordinate!, placeType: placeType, completion: completion)
    }
    
    func getNearbyPlaces(coordinate: CLLocationCoordinate2D, placeType: String, completion: @escaping (Result<GoogleNearbyPlacesResponse, Error>) -> Void) {
        let location = "\(coordinate.latitude),\(coordinate.longitude)"
        let baseUrl = "https://maps.googleapis.com/maps/api/place/nearbysearch/json"
        let parameters = [
            "location" : location,
            "radius" : String(LocationConstants.RADIUS),
            "key" : getAPIKey(),
            "type": placeType
        ] as [String : Any]
        var components = URLComponents(string: baseUrl)!
        components.queryItems = parameters.map { URLQueryItem(name: $0, value: $1 as? String) }
        guard let url = components.url else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        let session = URLSession.shared
        session.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
            }
            do {
                let response = try JSONDecoder().decode(GoogleNearbyPlacesResponse.self, from: data)
                completion(.success(response))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
