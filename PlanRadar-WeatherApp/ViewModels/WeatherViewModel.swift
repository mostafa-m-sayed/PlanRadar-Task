//
//  WeatherViewModel.swift
//  PlanRadar-WeatherApp
//
//  Created by Mostafa Sayed on 03/10/2025.
//
import Combine
import Foundation

final class WeatherViewModel: ObservableObject {
    
    @Published var weatherData: WeatherResponse?
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    var repository: WeatherRepository

    init() {
        repository = WeatherRepository()
//        self.weatherData = WeatherResponse(weather: WeatherDetailsDescription(description: "Rainy", icon: "10d"), main: WeatherMainData(temp: 315, humidity: 80), wind: WeatherWindDetails(speed: 32))
    }
    
    func fetchWeather(for city: String) async {
        isLoading = true
        do {
            weatherData = try await repository.fetchWeather(for: city)
            
            isLoading = false
        } catch let error {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }
    
    func saveCity(name: String) {
        CoreDataManager.shared.saveCity(name: name)
    }
}
