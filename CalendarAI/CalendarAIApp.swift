//
//  CalendarAIApp.swift
//  CalendarAI
//
//  Created by Shubham Chawla on 11/22/23.
//

import SwiftUI

@main
struct CalendarAIApp: App {
    private let locationService = LocationService()
    private let dataService = DataService()
    private let calendarService = CalendarService()
    private let generativeAIService = GenerativeAIService()
    private let cameraService = CameraService()
    private let measurementService = MeasurementService()
    private let weatherService = WeatherService()
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(\.managedObjectContext, self.dataService.container.viewContext)
                .environmentObject(self.locationService)
                .environmentObject(self.dataService)
                .environmentObject(self.calendarService)
                .environmentObject(self.generativeAIService)
                .environmentObject(self.cameraService)
                .environmentObject(self.measurementService)
                .environmentObject(self.weatherService)
                .onAppear {
                    self.calendarService.requestCalendarReadAccess()
                    self.locationService.requestLocationAccess()
                }
        }
    }
}
