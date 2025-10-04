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
    var saveToCoreData: Bool = true

    var repository: WeatherRepository
    var weatherService: WeatherService

    init() {
        repository = WeatherRepository()
        weatherService = WeatherService()
    }
    
    /// Fetch weather data from Swift network manager using the repository
    /// umcomment to use it
//    func fetchWeather(for city: String) async {
//        saveToCoreData = true
//        isLoading = true
//        do {
//            weatherData = try await repository.fetchWeather(for: city)
//            
//            isLoading = false
//        } catch let error {
//            errorMessage = error.localizedDescription
//            isLoading = false
//        }
//    }
    /// Fetch weather data from Obj-C network manager using the service
    
    func fetchWeather(for city: String) async {
        saveToCoreData = false
        isLoading = true
        weatherService.fetchAndSaveWeather(for: city) { [weak self] response in
            self?.isLoading = false
            switch response {
            case .success(let weatherResponse):
                self?.weatherData = weatherResponse
            case .failure(let error):
                self?.errorMessage = error.localizedDescription
            }
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
