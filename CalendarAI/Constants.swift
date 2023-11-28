//
//  Constants.swift
//  CalendarAI
//
//  Created by Ujjwal Sharma on 27/11/23.
//

import Foundation


public struct MeasurementConstants {
    
    // Common constants
    static let MAX_TIME_DURATION = 45
    
    // Heart rate measurement related constants
    static let STARTING_FRAME_COUNT = 10
    static let FRAME_INTERVAL = 5
    static let AVERAGE_DIFFERENCE_THRESHOLD = 210000
    
    // Resp rate measurement related constants
    static let ACCELEROMETER_INTERVAL = 0.1
    static let ACCELEROMETER_DIFFERENCE_THRESHOLD = 0.15
    
}
