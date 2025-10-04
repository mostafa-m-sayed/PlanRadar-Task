//
//  WeatherViewModel.swift
//  PlanRadar-WeatherApp
//
//  Created by Mostafa Sayed on 03/10/2025.
//
import Combine
import Foundation
import SwiftUI

final class WeatherViewModel: ObservableObject {

    @Published var weatherData: WeatherResponse?
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    @Published var cities: [City] = []
    @Published var weatherHistory: [WeatherInfo] = []
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
        cities = CoreDataManager.shared.fetchAllCities()
    }

    func loadCities(isPreview: Bool = false) {
        if isPreview {
            #if DEBUG
            loadDummyCities()
            #endif
        } else {
            cities = CoreDataManager.shared.fetchAllCities()
        }
    }

    func deleteCity(at offsets: IndexSet) {
        offsets.forEach { index in
            let city = cities[index]
            CoreDataManager.shared.deleteCity(city)
        }
        cities.remove(atOffsets: offsets)
    }

    func loadWeatherHistory(for city: City) {
        weatherHistory = CoreDataManager.shared.fetchWeatherHistory(for: city)
    }

    #if DEBUG
    private func loadDummyCities() {
        guard cities.isEmpty else { return }

        let coreDataManager = CoreDataManager.shared
        let dummyCityNames = ["London", "Vienna", "Paris"]
        let dummyCityIds: [Int64] = [2643743, 2761369, 2988507]

        for (index, cityName) in dummyCityNames.enumerated() {
            if coreDataManager.fetchCity(byName: cityName) == nil {
                _ = coreDataManager.fetchOrCreateCity(
                    name: cityName,
                    cityId: dummyCityIds[index]
                )
            }
        }

        coreDataManager.saveContext()
        cities = coreDataManager.fetchAllCities()
    }
    #endif
}
