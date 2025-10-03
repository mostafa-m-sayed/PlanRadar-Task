//
//  WeatherViewModel.swift
//  PlanRadar-WeatherApp
//
//  Created by Mostafa Sayed on 03/10/2025.
//
import Combine
import Foundation

class WeatherViewModel: ObservableObject {
    
    @Published var weatherData: WeatherResponse?
    
    init() {
        self.weatherData = WeatherResponse(weather: WeatherDetailsDescription(description: "Rainy", icon: "10d"), main: WeatherMainData(temp: 315, humidity: 80), wind: WeatherWindDetails(speed: 32))
    }
    
    func fetchWeather(for city: String) {
        
    }
        
}
