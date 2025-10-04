//
//  WeatherWindDetails.swift
//  PlanRadar-WeatherApp
//
//  Created by Mostafa Sayed on 03/10/2025.
//
import Foundation

struct WeatherWindDetails: Codable {
    let speed: Double
    
    var speedString: String {
        return String(format: "%.1f km/h", speed)
    }
}
