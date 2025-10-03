//
//  CoreDataManager.swift
//  PlanRadar-WeatherApp
//

import Foundation
import CoreData

class CoreDataManager {

    static let shared = CoreDataManager()

    private init() {}

    // MARK: - Core Data Stack

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "PlanRadar_WeatherApp")
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()

    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    // MARK: - Core Data Saving

    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    // MARK: - City Operations

    func fetchCity(byName name: String) -> City? {
        let fetchRequest: NSFetchRequest<City> = City.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", name)

        do {
            let cities = try context.fetch(fetchRequest)
            return cities.first
        } catch {
            print("Error fetching city: \(error)")
            return nil
        }
    }

    func fetchOrCreateCity(name: String, cityId: Int64) -> City {
        if let existingCity = fetchCity(byName: name) {
            return existingCity
        }

        let city = City(context: context)
        city.name = name
        city.cityId = cityId
        return city
    }

    func fetchAllCities() -> [City] {
        let fetchRequest: NSFetchRequest<City> = City.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]

        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Error fetching cities: \(error)")
            return []
        }
    }

    func deleteCity(_ city: City) {
        context.delete(city)
        saveContext()
    }

    // MARK: - Weather Info Operations

    func saveWeatherInfo(for city: City, weatherData: [AnyHashable: Any]) {
        let weatherInfo = WeatherInfo(context: context)
        weatherInfo.requestDate = Date()
        weatherInfo.city = city

        // Extract weather description
        if let weather = weatherData["weather"] as? [[String: Any]],
           let firstWeather = weather.first,
           let description = firstWeather["description"] as? String {
            weatherInfo.weatherDescription = description
        }

        // Extract icon ID
        if let weather = weatherData["weather"] as? [[String: Any]],
           let firstWeather = weather.first,
           let icon = firstWeather["icon"] as? String {
            weatherInfo.iconId = icon
        }

        // Extract temperature (convert from Kelvin to Celsius)
        if let main = weatherData["main"] as? [String: Any],
           let tempKelvin = main["temp"] as? Double {
            weatherInfo.temperature = tempKelvin - 273.15
        }

        // Extract humidity
        if let main = weatherData["main"] as? [String: Any],
           let humidity = main["humidity"] as? Int64 {
            weatherInfo.humidity = humidity
        }

        // Extract wind speed
        if let wind = weatherData["wind"] as? [String: Any],
           let speed = wind["speed"] as? Double {
            weatherInfo.windSpeed = speed
        }

        saveContext()
    }

    func fetchWeatherHistory(for city: City) -> [WeatherInfo] {
        guard let weatherHistory = city.weatherHistory as? Set<WeatherInfo> else {
            return []
        }

        return weatherHistory.sorted { $0.requestDate ?? Date() > $1.requestDate ?? Date() }
    }

    func deleteAllData() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = City.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            print("Error deleting all data: \(error)")
        }
    }
}
