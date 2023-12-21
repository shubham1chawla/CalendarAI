//
//  WeatherCardsViewModel.swift
//  WellnessAI
//
//  Created by Shubham Chawla on 12/21/23.
//

import Foundation
import CoreLocation

extension WeatherCardsView {
    @MainActor class ViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
        
        private var locationManager: CLLocationManager?
        
        @Published var hasLocationAccess: Bool = false
        @Published var currentLocation: CLLocation?
        
        func requestLocationAccess() -> Void {
            locationManager = CLLocationManager()
            locationManager?.delegate = self
            locationManager?.desiredAccuracy = kCLLocationAccuracyBest
            locationManager?.requestWhenInUseAuthorization()
        }
        
        nonisolated func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
            Task { @MainActor in
                switch status {
                case .authorized:
                    fallthrough
                case .authorizedAlways:
                    fallthrough
                case .authorizedWhenInUse:
                    hasLocationAccess = true
                    locationManager?.startUpdatingLocation()
                    break
                default:
                    hasLocationAccess = false
                }
            }
        }
        
        nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            Task { @MainActor in
                guard let currentLocation = locations.last else { return }
                self.currentLocation = currentLocation
                locationManager?.stopUpdatingLocation()
            }
        }
        
        func callOpenWeatherAPI() -> Void {
            
        }
        
    }
}
