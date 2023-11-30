//
//  WeatherWelcomeView.swift
//  CalendarAI
//
//  Created by Aashna Budhiraja on 11/22/23.
//

import SwiftUI
import CoreLocationUI

struct WeatherWelcomeView: View {
    
    @EnvironmentObject var locationManager: WeatherLocationService
    
    var body: some View {
        VStack {
            VStack(spacing: 20) {
                Text("Share your location to get the weather in your area").padding()
            }
            .multilineTextAlignment(.center)
            .padding()
            
            LocationButton(.shareCurrentLocation) {
                locationManager.requestLocation()
            }
            .cornerRadius(30)
            .symbolVariant(.fill)
            .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WeatherWelcomeView()
    }
}
