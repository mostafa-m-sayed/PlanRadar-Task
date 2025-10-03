//
//  WeatherDetailsDescription.swift
//  PlanRadar-WeatherApp
//
//  Created by Mostafa Sayed on 03/10/2025.
//

struct WeatherDetailsDescription: Codable {
    let description: String
    let icon: String
    
    var iconURL: String {
        return "https://openweathermap.org/img/w/\(icon).png"
    }
}
