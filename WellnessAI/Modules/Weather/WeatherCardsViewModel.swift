//
//  WeatherCardsViewModel.swift
//  WellnessAI
//
//  Created by Shubham Chawla on 12/21/23.
//

import Foundation
import CoreLocation
import CoreData

let iconSystemNameMapping: [String: String] = [
    "01d": "sun.max.fill",
    "01n": "moon.fill",
    "02d": "cloud.sun.fill",
    "02n": "cloud.moon.fill",
    "03d": "cloud.fill",
    "03n": "cloud.fill",
    "04d": "smoke.fill",
    "04n": "smoke.fill",
    "09d": "cloud.rain.fill",
    "09n": "cloud.rain.fill",
    "10d": "cloud.rain.fill",
    "10n": "cloud.rain.fill",
    "11d": "cloud.bolt.rain.fill",
    "11n": "cloud.bolt.rain.fill",
    "13d": "snowflake",
    "13n": "snowflake",
    "50d": "sun.haze.fill",
    "50n": "moon.haze.fill"
]

struct OpenWeatherAPIResponse: Decodable {
    let cod: Int?
    let message: String?
    let name: String?
    let visibility: Double?
    let weather: [OpenWeatherAPIResponseWeather]?
    let main: OpenWeatherAPIResponseMain?
    let wind: OpenWeatherAPIResponseWind?
    let coord: OpenWeatherAPIResponseCoord?
}

struct OpenWeatherAPIResponseWeather: Decodable {
    let main: String?
    let description: String?
    let icon: String?
}

struct OpenWeatherAPIResponseMain: Decodable {
    let temp: Double?
    let feels_like: Double?
    let temp_min: Double?
    let temp_max: Double?
    let pressure: Double?
    let humidity: Double?
}

struct OpenWeatherAPIResponseWind: Decodable {
    let speed: Double?
}

struct OpenWeatherAPIResponseCoord: Decodable {
    let lat: Double?
    let lon: Double?
}

extension WeatherCardsView {
    @MainActor class ViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
        
        private var context: NSManagedObjectContext?
        private var locationManager: CLLocationManager?
        private let defaults = UserDefaults.standard
        private let units = "metric"
        
        @Published private(set) var errorMessage: String? = nil
        @Published private(set) var userSessions: [UserSession] = []
        @Published private(set) var isAwaitingAPIResponse: Bool = false
        
        var isError: Bool {
            return !(errorMessage ?? "").isEmpty
        }
        
        func refreshWeatherInformation(context: NSManagedObjectContext, force: Bool = false) -> Void {
            self.context = context
            self.errorMessage = nil
            
            // Loading weather sessions from database
            setUserSessionsWithWeather()
            
            if shouldCallOpenWeatherAPI(force: force) {
                locationManager = CLLocationManager()
                locationManager?.delegate = self
                locationManager?.desiredAccuracy = kCLLocationAccuracyBest
                locationManager?.requestWhenInUseAuthorization()
            }
        }
        
        private func shouldCallOpenWeatherAPI(force: Bool) -> Bool {
            if isAwaitingAPIResponse { return false }
            if force { return true }
            if userSessions.isEmpty { return true }
            
            let userSession = userSessions.first
            let timestamp = userSession?.timestamp ?? Date()
            return abs(Int(timestamp.timeIntervalSinceNow)) > APIConstants.API_THROTTLING_TIMEOUT
        }
        
        nonisolated func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
            Task { @MainActor in
                switch status {
                case .authorized:
                    fallthrough
                case .authorizedAlways:
                    fallthrough
                case .authorizedWhenInUse:
                    locationManager?.startUpdatingLocation()
                    break
                default:
                    errorMessage = "Unable to access your location!"
                }
            }
        }
        
        nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            guard let currentLocation = locations.last else { return }
            manager.stopUpdatingLocation()
            Task { @MainActor in
                callOpenWeatherAPI(for: currentLocation)
            }
        }
        
        private func callOpenWeatherAPI(for location: CLLocation) -> Void {
            let appid = defaults.string(forKey: Keys.OPEN_WEATHER_API_KEY_IDENTIFIER)
            if (appid ?? "").isEmpty {
                errorMessage = "OpenWeather API key not set in Settings!"
                return
            }
            
            // Preventing duplicate API calls
            guard !isAwaitingAPIResponse else { return }
            isAwaitingAPIResponse = true
            
            var components = URLComponents(string: "https://api.openweathermap.org/data/2.5/weather")!
            components.queryItems = [
                URLQueryItem(name: "lat", value: "\(location.coordinate.latitude)"),
                URLQueryItem(name: "lon", value: "\(location.coordinate.longitude)"),
                URLQueryItem(name: "units", value: units),
                URLQueryItem(name: "appid", value: appid)
            ]
            
            let request = URLRequest(url: components.url!)
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                Task { @MainActor in
                    do {
                        defer {
                            self.isAwaitingAPIResponse = false
                        }
                        if let error = error {
                            throw error
                        }
                        let response = try JSONDecoder().decode(OpenWeatherAPIResponse.self, from: data!)
                        self.saveWeather(from: response)
                        self.setUserSessionsWithWeather()
                    } catch {
                        self.errorMessage = error.localizedDescription
                    }
                }
            }
            task.resume()
        }
        
        private func saveWeather(from response: OpenWeatherAPIResponse) -> Void {
            guard let context = context else { return }
            guard response.cod == 200 else {
                errorMessage = response.message
                return
            }
            
            // Converting response to CoreData entity
            let weather = Weather(context: context)
            weather.locationName = response.name
            weather.weatherMain = response.weather?.first?.main
            weather.weatherDescription = response.weather?.first?.description
            weather.iconSystemName = iconSystemNameMapping[response.weather?.first?.icon ?? ""]
            weather.currentTemp = response.main?.temp ?? weather.currentTemp
            weather.feelsLikeTemp = response.main?.feels_like ?? weather.feelsLikeTemp
            weather.minTemp = response.main?.temp_min ?? weather.minTemp
            weather.maxTemp = response.main?.temp_max ??  weather.maxTemp
            weather.pressure = response.main?.pressure ?? weather.pressure
            weather.humidity = response.main?.humidity ?? weather.humidity
            weather.visibility = response.visibility ?? weather.visibility
            weather.windSpeed = response.wind?.speed ?? weather.windSpeed
            weather.latitude = response.coord?.lat ?? weather.latitude
            weather.longitude = response.coord?.lon ?? weather.longitude
            weather.units = units
            
            // Connecting weather entity to session and persisting
            weather.userSession = getCurrentUserSession(context: context)
            try? context.save()
        }
        
        private func getCurrentUserSession(context: NSManagedObjectContext) -> UserSession {
            // Extracting user session id from defaults
            let uuid = defaults.string(forKey: Keys.LAST_USER_SESSSION)
            if (uuid ?? "").isEmpty {
                fatalError("No user session was set!")
            }
            
            let request = UserSession.fetchRequest()
            request.predicate = NSPredicate(format: "uuid CONTAINS %@", uuid!)
            let userSessions = try! context.fetch(request)
            let userSession = userSessions.first ?? UserSession(context: context)
            userSession.uuid = userSession.uuid ?? uuid!
            userSession.timestamp = Date()
            return userSession
        }
        
        private func setUserSessionsWithWeather() -> Void {
            guard let context = context else { return }
            
            // Loading weathers from user sessions stored in database
            let request = UserSession.fetchRequest()
            request.predicate = NSPredicate(format: "weather != nil")
            request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
            
            var userSessions: [UserSession] = []
            for userSession in try! context.fetch(request) {
                userSessions.append(userSession)
            }
            self.userSessions = userSessions
        }
        
    }
}
