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
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(self.locationService)
                .onAppear {
                    self.locationService.requestLocationAccess()
                }
        }
    }
}
