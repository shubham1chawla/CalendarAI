//
//  WeatherDetailView.swift
//  CalendarAI
//
//  Created by Aashna Budhiraja on 11/22/23.
//

import SwiftUI

let iconMap: [String: String] = [
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

func determineDrivingConditions(rainInLastHour: Double, snowInLastHour: Double, visibility: Double, windSpeed: Double) -> [String] {
    let poorVisibilityThreshold: Double = 500.0
    let moderateVisibilityThreshold: Double = 1000.0
    let highRainThreshold: Double = 5.0
    let moderateRainThreshold: Double = 2.0
    let highSnowThreshold: Double = 5.0
    let moderateSnowThreshold: Double = 1.0
    let highWindSpeedThreshold: Double = 10.0
    let moderateWindSpeedThreshold: Double = 5.0

    if visibility < poorVisibilityThreshold {
        return ["poor", "Poor driving conditions due to low visibility."]
    } else if visibility < moderateVisibilityThreshold {
        return ["moderate", "Moderate driving conditions with reduced visibility."]
    } else if rainInLastHour > highRainThreshold {
        return ["poor", "Poor driving conditions due to heavy rain."]
    } else if rainInLastHour > moderateRainThreshold {
        return ["moderate", "Moderate driving conditions with moderate rain."]
    } else if snowInLastHour > highSnowThreshold {
        return ["poor", "Poor driving conditions due to heavy snow."]
    } else if snowInLastHour > moderateSnowThreshold {
        return ["moderate", "Moderate driving conditions with moderate snow."]
    } else if windSpeed > highWindSpeedThreshold {
        return ["poor", "Poor driving conditions due to high wind speed."]
    } else if windSpeed > moderateWindSpeedThreshold {
        return ["moderate", "Moderate driving conditions with moderate wind speed."]
    } else {
        return ["good", "Good driving conditions."]
    }
}

struct WeatherDetailView: View {
    var weather: ResponseBody
    
    var body: some View {
        ZStack(alignment: .leading) {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 5) {
                    Text(weather.name).bold().font(.title)
                    Text("\(Date().formatted(.dateTime.month().day().hour().minute()))").fontWeight(.light)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                Spacer()
                
                let oneHourRain = weather.rain?.one_hour ?? 0.0
                let wind = weather.wind.speed
                let visibility = weather.visibility
                let oneHourSnow = weather.snow?.one_hour ?? 0.0
                
                let drivingConditions = determineDrivingConditions(rainInLastHour: oneHourRain, snowInLastHour: oneHourSnow, visibility: visibility, windSpeed: wind)
                
                if(drivingConditions[0] == "poor") {
                    VStack() {
                        Text("Warning: "+drivingConditions[1]).bold().font(.system(size: 20)).font(.title)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading).background(Color.red)
                    .cornerRadius(20)
                } else if(drivingConditions[0] == "moderate") {
                    VStack() {
                        Text(drivingConditions[1]).bold().font(.system(size: 20)).font(.title)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading).background(Color.yellow)
                    .cornerRadius(20)
                } else if(drivingConditions[0] == "good") {
                    VStack() {
                        Text(drivingConditions[1]).bold().font(.system(size: 20)).font(.title)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading).background(Color.green)
                    .cornerRadius(20)
                }
                
                Spacer()
                
                VStack {
                    HStack {
                        VStack(spacing: 20) {
                            Image(systemName: iconMap[weather.weather[0].icon] ?? "rainbow").font(.system(size: 40))
                            Text(weather.weather[0].description.capitalizeEachWord()).font(.system(size: 30)).fontWeight(.bold)
                        }
                        .frame(width: 150, alignment: .leading)
                        Spacer()
                        
                        VStack(spacing: 20) {
                            Text(weather.main.temp.roundDouble() + "°").font(.system(size: 70)).fontWeight(.bold)
                            Text("Feels like: " + weather.main.feels_like.roundDouble() + "°")
                        }
                    }
                    Spacer()
                    
                }
                .frame(maxWidth: .infinity)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            
//            Spacer()
            
            VStack {
                Spacer()
                VStack(alignment: .leading, spacing: 20) {
                    Text("Weather Details").bold().padding(.bottom)
                    
                    HStack(spacing: 50){
                        HStack {
                            Image(systemName: "thermometer").font(.title2).frame(width: 20, height: 20)
                                                            .padding()
                                                            .background(Color(hue: 1.0, saturation: 0.0, brightness: 0.888))
                                                            .cornerRadius(50)

                            VStack(alignment: .leading, spacing: 8) {
                                Text("Min Temp                ").font(.caption)
                                Text(weather.main.temp_min.roundDouble() + "°").font(.system(size: 25))
                            }
                        }
//                        Spacer()
                        
                        HStack {
                            Image(systemName: "thermometer").font(.title2).frame(width: 20, height: 20)
                                                            .padding()
                                                            .background(Color(hue: 1.0, saturation: 0.0, brightness: 0.888))
                                                            .cornerRadius(50)

                            VStack(alignment: .leading, spacing: 8) {
                                Text("Max Temp                ").font(.caption)
                                Text(weather.main.temp_max.roundDouble() + "°").font(.system(size: 25))
                            }
                        }
                    }
                    
                    HStack(spacing: 50){
                        
                        HStack() {
                            Image(systemName: "wind").font(.title2).frame(width: 20, height: 20)
                                                            .padding()
                                                            .background(Color(hue: 1.0, saturation: 0.0, brightness: 0.888))
                                                            .cornerRadius(50)

                            VStack(alignment: .leading, spacing: 8) {
                                Text("Wind Speed                 ").font(.caption)

                                Text(weather.wind.speed.roundDouble() + "m/s").font(.system(size: 25))
                            }
                        }
//                        Spacer()
                        
                        HStack() {
                            Image(systemName: "humidity").font(.title2).frame(width: 20, height: 20)
                                                        .padding()
                                                        .background(Color(hue: 1.0, saturation: 0.0, brightness: 0.888))
                                                        .cornerRadius(50)

                            VStack(alignment: .leading, spacing: 8) {
                                Text("Humidity                 ").font(.caption)
                                Text(weather.main.humidity.roundDouble() + "%").font(.system(size: 25))
                            }
                        }
                    }
                    HStack(spacing: 50){
                        HStack() {
                            Image(systemName: "eye").font(.title2).frame(width: 20, height: 20)
                                                            .padding()
                                                            .background(Color(hue: 1.0, saturation: 0.0, brightness: 0.888))
                                                            .cornerRadius(50)

                            VStack(alignment: .leading, spacing: 8) {
                                Text("Visibility              ").font(.caption)
                                
                                let text = weather.visibility > 1000 ? String(format: "%.0f", weather.visibility/1000) + "km" : weather.visibility.roundDouble() + "m"

                                Text(text).font(.system(size: 25))
                            }
                        }
                        
                        HStack() {
                            Image(systemName: "gauge.open.with.lines.needle.33percent").font(.title2).frame(width: 20, height: 20)
                                                        .padding()
                                                        .background(Color(hue: 1.0, saturation: 0.0, brightness: 0.888))
                                                        .cornerRadius(50)
                            
                            let text = weather.main.pressure > 1000 ? String(format: "%.0f", weather.visibility/1000) + " khPa" : weather.visibility.roundDouble() + " hPa"

                            VStack(alignment: .leading, spacing: 8) {
                                Text("Pressure                  ").font(.caption)
                                Text(text).font(.system(size: 25))
                            }
                        }
                    }
                    HStack(spacing: 50){
                        HStack() {
                            Image(systemName: "cloud.rain").font(.title2).frame(width: 20, height: 20)
                                                            .padding()
                                                            .background(Color(hue: 1.0, saturation: 0.0, brightness: 0.888))
                                                            .cornerRadius(50)

                            VStack(alignment: .leading, spacing: 8) {
                                Text("Rain (last hr.)                ").font(.caption)
                                if let oneHourRain = weather.rain?.one_hour {
                                    Text(oneHourRain.roundDouble() + "mm").font(.system(size: 25))
                                } else {
                                    Text("0mm").font(.system(size: 25))
                                }
                            }
                        }
                        
                        HStack() {
                            Image(systemName: "cloud.snow").font(.title2).frame(width: 20, height: 20)
                                                        .padding()
                                                        .background(Color(hue: 1.0, saturation: 0.0, brightness: 0.888))
                                                        .cornerRadius(50)

                            VStack(alignment: .leading, spacing: 8) {
                                Text("Snow (last hr.)    ").font(.caption)
                                if let oneHourSnow = weather.snow?.one_hour {
                                    Text(oneHourSnow.roundDouble() + "mm").font(.system(size: 25))
                                } else {
                                    Text("0mm").font(.system(size: 25))
                                }
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .padding(.bottom, 20)
                .foregroundColor(Color(hue: 0.656, saturation: 0.787, brightness: 0.354))
                .background(.white)
                .cornerRadius(20)
            }
            
            
        }
        .edgesIgnoringSafeArea(.bottom)
        .background(Color(red: 0.0, green: 0.2, blue: 0.6))
    }
}

extension Double {
    func roundDouble() -> String {
        return String(format: "%.0f", self)
    }
}

extension String {
    func capitalizeEachWord() -> String {
        let words = components(separatedBy: " ")
        let capitalizedWords = words.map { $0.capitalized }
        return capitalizedWords.joined(separator: " ")
    }
}
