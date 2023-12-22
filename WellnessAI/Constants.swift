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
    static let AVERAGE_DIFFERENCE_THRESHOLD = 210000
    static let ACCELEROMETER_INTERVAL = 0.1
    static let ACCELEROMETER_DIFFERENCE_THRESHOLD = 0.15
}
