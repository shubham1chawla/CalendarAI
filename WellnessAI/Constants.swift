//
//  Constants.swift
//  WellnessAI
//
//  Created by Shubham Chawla on 12/18/23.
//

import Foundation

struct Keys {
    static let APPLICATION_NAME = "WellnessAI"
    static let LAST_USER_SESSSION = "lastUserSession"
    static let IS_DEVELOPER_MODE_ENABLED = "isDeveloperModeEnabled"
    static let OPEN_WEATHER_API_KEY_IDENTIFIER = "openWeatherKey"
}

struct MeasurementConstants {
    static let MAX_TIME_DURATION = 45
    static let STARTING_FRAME_COUNT = 10
    static let FRAME_INTERVAL = 5
    static let AVERAGE_DIFFERENCE_THRESHOLD = 210_000
    static let ACCELEROMETER_INTERVAL = 0.1
    static let ACCELEROMETER_DIFFERENCE_THRESHOLD = 0.15
}

struct APIConstants {
    static let API_THROTTLING_TIMEOUT = 5 * 60
    static let GOOGLE_NEARBY_PLACES_RADIUS = 5_000
    static let OPEN_WEATHER_UNITS = "metric"
}

struct WeatherConstants {
    static let ICON_TO_SYSTEM_NAME_MAPPING = [
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
    
    static func getSystemName(forIcon: String) -> String? {
        return WeatherConstants.ICON_TO_SYSTEM_NAME_MAPPING[forIcon]
    }
}
