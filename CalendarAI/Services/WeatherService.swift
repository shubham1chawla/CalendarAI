//
//  WeatherService.swift
//  CalendarAI
//
//  Created by Aashna Budhiraja on 11/22/23.
//

import Foundation
import CoreLocation

class WeatherService: ObservableObject {
    
    private func getAPIKey() -> String {
        let key = UserDefaults.standard.string(forKey: Keys.OPEN_WEATHER_API_KEY_IDENTIFIER)
        if (key == nil || key!.isEmpty) {
            fatalError("Please provide a valid Open Weather API key in Settings!")
        }
        return key!
    }
    
    func getCurrentWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees) async throws -> ResponseBody {
        let latitude = "\(latitude)"
        let longitude = "\(longitude)"
        let baseUrl = "https://api.openweathermap.org/data/2.5/weather"
        let parameters = [
            "lat": latitude,
            "lon": longitude,
            "appid": getAPIKey(),
            "units": "metric"
        ] as [String: Any]

        var components = URLComponents(string: baseUrl)!

        components.queryItems = parameters.map { URLQueryItem(name: $0, value: $1 as? String) }

        guard let url = components.url else { fatalError("Invalid URL components") }
        print(url)

        let urlRequest = URLRequest(url: url)

        let (data, response) = try await URLSession.shared.data(for: urlRequest)

        guard (response as? HTTPURLResponse)?.statusCode == 200 else { fatalError("Error while fetching data") }

        let decodedData = try JSONDecoder().decode(ResponseBody.self, from: data)
        
//        print(decodedData)

        return decodedData
    }
}

struct ResponseBody: Decodable {
    var coord: CoordinatesResponse
    var weather: [WeatherResponse]
    var main: MainResponse
    var name: String
    var wind: WindResponse
    var visibility: Double
    var rain: RainResponse?
    var snow: SnowResponse?

    struct CoordinatesResponse: Decodable {
        var lon: Double
        var lat: Double
    }

    struct WeatherResponse: Decodable {
        var id: Double
        var main: String
        var description: String
        var icon: String
    }

    struct MainResponse: Decodable {
        var temp: Double
        var feels_like: Double
        var temp_min: Double
        var temp_max: Double
        var pressure: Double
        var humidity: Double
    }

    struct WindResponse: Decodable {
        var speed: Double
        var deg: Double
    }
    
    struct RainResponse: Decodable {
        var one_hour: Double?
        var three_hours: Double?
    }
    
    struct SnowResponse: Decodable {
        var one_hour: Double?
        var three_hours: Double?
    }
}
