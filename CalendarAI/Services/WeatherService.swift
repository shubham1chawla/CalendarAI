//
//  WeatherService.swift
//  CalendarAI
//
//  Created by Aashna Budhiraja on 11/22/23.
//

import Foundation
import CoreLocation

let API_KEY = "ADD-YOUR-API-KEY-HERE"

class WeatherService {
    func getCurrentWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees) async throws -> ResponseBody {
        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&appid=\(API_KEY)&units=metric") else { fatalError("Missing URL") }

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
