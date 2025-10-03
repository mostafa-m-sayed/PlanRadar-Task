//  WeatherMainData.swift
//  PlanRadar-WeatherApp
//
//  Created by Mostafa Sayed on 03/10/2025.
//

import Foundation

struct WeatherMainData: Codable {
    let temp: Double
    let humidity: Int
    
    private var tempCelsius: Double {
        temp - 273.15
    }
    
    var temperatureString: String {
        return String(format: "%.1f ℃", tempCelsius)
    }
    var himidityString: String {
        return "\(humidity)%"
    }
    
}
