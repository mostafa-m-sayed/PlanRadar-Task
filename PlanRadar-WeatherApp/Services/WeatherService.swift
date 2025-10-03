//
//  WeatherService.swift
//  PlanRadar-WeatherApp
//

import Foundation

class WeatherService {

    static let shared = WeatherService()

    private let networkManager: WeatherNetworkManager
    private let coreDataManager: CoreDataManager

    init(networkManager: WeatherNetworkManager = .shared(),
         coreDataManager: CoreDataManager = .shared) {
        self.networkManager = networkManager
        self.coreDataManager = coreDataManager
    }

    // MARK: - Fetch and Save Weather

    func fetchAndSaveWeather(for cityName: String, completion: @escaping (Result<[String: Any], Error>) -> Void) {
        networkManager.fetchWeather(forCity: cityName) { [weak self] weatherData, error in
            guard let self = self else { return }

            if let error = error {
                completion(.failure(error))
                return
            }

            guard let weatherData = weatherData else {
                let error = NSError(domain: "WeatherService",
                                  code: -1,
                                  userInfo: [NSLocalizedDescriptionKey: "No weather data received"])
                completion(.failure(error))
                return
            }

            // Extract city ID from response
            let cityId = weatherData["id"] as? Int64 ?? 0

            // Fetch or create city
            let city = self.coreDataManager.fetchOrCreateCity(name: cityName, cityId: cityId)

            // Save weather info to CoreData
            self.coreDataManager.saveWeatherInfo(for: city, weatherData: weatherData)

            completion(.success(weatherData as! [String : Any]))
        }
    }

    // MARK: - City Management

    func fetchAllCities() -> [City] {
        return coreDataManager.fetchAllCities()
    }

    func addCity(name: String, completion: @escaping (Result<Void, Error>) -> Void) {
        // Check if city already exists
        if coreDataManager.fetchCity(byName: name) != nil {
            let error = NSError(domain: "WeatherService",
                              code: -2,
                              userInfo: [NSLocalizedDescriptionKey: "City already exists"])
            completion(.failure(error))
            return
        }

        // Fetch weather to validate city and get city ID
        fetchAndSaveWeather(for: name) { result in
            switch result {
            case .success:
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func deleteCity(_ city: City) {
        coreDataManager.deleteCity(city)
    }

    // MARK: - Weather History

    func fetchWeatherHistory(for city: City) -> [WeatherInfo] {
        return coreDataManager.fetchWeatherHistory(for: city)
    }

    // MARK: - Icon Fetching

    func fetchWeatherIcon(iconId: String, completion: @escaping (Result<Data, Error>) -> Void) {
        networkManager.fetchWeatherIcon(withId: iconId) { imageData, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let imageData = imageData else {
                let error = NSError(domain: "WeatherService",
                                  code: -3,
                                  userInfo: [NSLocalizedDescriptionKey: "No icon data received"])
                completion(.failure(error))
                return
            }

            completion(.success(imageData))
        }
    }
}
