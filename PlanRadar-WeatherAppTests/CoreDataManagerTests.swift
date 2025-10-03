//
//  CoreDataManagerTests.swift
//  PlanRadar-WeatherAppTests
//

import XCTest
import CoreData
@testable import PlanRadar_WeatherApp

final class CoreDataManagerTests: XCTestCase {

    var coreDataManager: CoreDataManager!
    var mockPersistentContainer: NSPersistentContainer!

    override func setUp() {
        super.setUp()

        // Create in-memory persistent container for testing
        mockPersistentContainer = {
            let container = NSPersistentContainer(name: "PlanRadar_WeatherApp")
            let description = NSPersistentStoreDescription()
            description.type = NSInMemoryStoreType
            container.persistentStoreDescriptions = [description]

            container.loadPersistentStores { (description, error) in
                if let error = error {
                    fatalError("Failed to load in-memory store: \(error)")
                }
            }
            return container
        }()

        coreDataManager = CoreDataManager.shared
        // Override the persistent container with in-memory one
        coreDataManager.persistentContainer = mockPersistentContainer
    }

    override func tearDown() {
        // Clean up all data
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = City.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        try? coreDataManager.context.execute(deleteRequest)
        try? coreDataManager.context.save()

        coreDataManager = nil
        mockPersistentContainer = nil
        super.tearDown()
    }

    // MARK: - City Operations Tests

    func testFetchOrCreateCity() {
        let city = coreDataManager.fetchOrCreateCity(name: "London", cityId: 2643743)

        XCTAssertNotNil(city, "City should be created")
        XCTAssertEqual(city.name, "London", "City name should match")
        XCTAssertEqual(city.cityId, 2643743, "City ID should match")
    }

    func testFetchOrCreateCityReturnsExisting() {
        // Create first city
        let city1 = coreDataManager.fetchOrCreateCity(name: "London", cityId: 2643743)
        coreDataManager.saveContext()

        // Try to create same city again
        let city2 = coreDataManager.fetchOrCreateCity(name: "London", cityId: 2643743)

        XCTAssertEqual(city1, city2, "Should return the same city object")
    }

    func testFetchCityByName() {
        // Create city
        _ = coreDataManager.fetchOrCreateCity(name: "London", cityId: 2643743)
        coreDataManager.saveContext()

        // Fetch city
        let fetchedCity = coreDataManager.fetchCity(byName: "London")

        XCTAssertNotNil(fetchedCity, "Should fetch existing city")
        XCTAssertEqual(fetchedCity?.name, "London", "Fetched city name should match")
    }

    func testFetchCityByNameReturnsNilForNonexistent() {
        let fetchedCity = coreDataManager.fetchCity(byName: "Nonexistent")

        XCTAssertNil(fetchedCity, "Should return nil for nonexistent city")
    }

    func testFetchAllCities() {
        // Create multiple cities
        _ = coreDataManager.fetchOrCreateCity(name: "London", cityId: 2643743)
        _ = coreDataManager.fetchOrCreateCity(name: "Vienna", cityId: 2761369)
        _ = coreDataManager.fetchOrCreateCity(name: "Paris", cityId: 2988507)
        coreDataManager.saveContext()

        // Fetch all cities
        let cities = coreDataManager.fetchAllCities()

        XCTAssertEqual(cities.count, 3, "Should have 3 cities")

        let cityNames = cities.map { $0.name ?? "" }
        XCTAssertTrue(cityNames.contains("London"), "Should contain London")
        XCTAssertTrue(cityNames.contains("Vienna"), "Should contain Vienna")
        XCTAssertTrue(cityNames.contains("Paris"), "Should contain Paris")
    }

    func testDeleteCity() {
        // Create city
        let city = coreDataManager.fetchOrCreateCity(name: "London", cityId: 2643743)
        coreDataManager.saveContext()

        // Delete city
        coreDataManager.deleteCity(city)

        // Verify deletion
        let fetchedCity = coreDataManager.fetchCity(byName: "London")
        XCTAssertNil(fetchedCity, "City should be deleted")
    }

    // MARK: - Weather Info Operations Tests

    func testSaveWeatherInfo() {
        // Create city
        let city = coreDataManager.fetchOrCreateCity(name: "London", cityId: 2643743)

        // Mock weather data
        let weatherData: [String: Any] = [
            "weather": [["description": "broken clouds", "icon": "04d"]],
            "main": ["temp": 288.15, "humidity": 72],
            "wind": ["speed": 4.5]
        ]

        // Save weather info
        coreDataManager.saveWeatherInfo(for: city, weatherData: weatherData)

        // Fetch weather history
        let history = coreDataManager.fetchWeatherHistory(for: city)

        XCTAssertEqual(history.count, 1, "Should have 1 weather record")

        let weatherInfo = history.first!
        XCTAssertEqual(weatherInfo.weatherDescription, "broken clouds", "Description should match")
        XCTAssertEqual(weatherInfo.iconId, "04d", "Icon ID should match")
        XCTAssertEqual(weatherInfo.temperature, 15.0, accuracy: 0.1, "Temperature should be converted to Celsius")
        XCTAssertEqual(weatherInfo.humidity, 72, "Humidity should match")
        XCTAssertEqual(weatherInfo.windSpeed, 4.5, accuracy: 0.1, "Wind speed should match")
        XCTAssertNotNil(weatherInfo.requestDate, "Request date should be set")
    }

    func testSaveMultipleWeatherInfoRecords() {
        // Create city
        let city = coreDataManager.fetchOrCreateCity(name: "London", cityId: 2643743)

        // Save first weather info
        let weatherData1: [String: Any] = [
            "weather": [["description": "clear sky", "icon": "01d"]],
            "main": ["temp": 293.15, "humidity": 60],
            "wind": ["speed": 3.5]
        ]
        coreDataManager.saveWeatherInfo(for: city, weatherData: weatherData1)

        // Wait a bit to ensure different timestamps
        Thread.sleep(forTimeInterval: 0.1)

        // Save second weather info
        let weatherData2: [String: Any] = [
            "weather": [["description": "broken clouds", "icon": "04d"]],
            "main": ["temp": 288.15, "humidity": 72],
            "wind": ["speed": 4.5]
        ]
        coreDataManager.saveWeatherInfo(for: city, weatherData: weatherData2)

        // Fetch weather history
        let history = coreDataManager.fetchWeatherHistory(for: city)

        XCTAssertEqual(history.count, 2, "Should have 2 weather records")

        // Verify sorting (most recent first)
        XCTAssertTrue(history[0].requestDate! > history[1].requestDate!, "Records should be sorted by date descending")
    }

    func testFetchWeatherHistory() {
        // Create city
        let city = coreDataManager.fetchOrCreateCity(name: "London", cityId: 2643743)

        // Save weather info
        let weatherData: [String: Any] = [
            "weather": [["description": "broken clouds", "icon": "04d"]],
            "main": ["temp": 288.15, "humidity": 72],
            "wind": ["speed": 4.5]
        ]
        coreDataManager.saveWeatherInfo(for: city, weatherData: weatherData)

        // Fetch history
        let history = coreDataManager.fetchWeatherHistory(for: city)

        XCTAssertFalse(history.isEmpty, "History should not be empty")
        XCTAssertEqual(history.first?.city, city, "Weather info should be linked to city")
    }

    func testDeleteCityDeletesWeatherHistory() {
        // Create city
        let city = coreDataManager.fetchOrCreateCity(name: "London", cityId: 2643743)

        // Save weather info
        let weatherData: [String: Any] = [
            "weather": [["description": "broken clouds", "icon": "04d"]],
            "main": ["temp": 288.15, "humidity": 72],
            "wind": ["speed": 4.5]
        ]
        coreDataManager.saveWeatherInfo(for: city, weatherData: weatherData)

        // Verify weather info exists
        let historyBefore = coreDataManager.fetchWeatherHistory(for: city)
        XCTAssertEqual(historyBefore.count, 1, "Should have 1 weather record before deletion")

        // Delete city
        coreDataManager.deleteCity(city)

        // Verify city and weather info are deleted (cascade delete)
        let fetchedCity = coreDataManager.fetchCity(byName: "London")
        XCTAssertNil(fetchedCity, "City should be deleted")

        // Fetch all weather info to verify cascade delete
        let fetchRequest: NSFetchRequest<WeatherInfo> = WeatherInfo.fetchRequest()
        let weatherInfoCount = try? coreDataManager.context.fetch(fetchRequest).count
        XCTAssertEqual(weatherInfoCount, 0, "Weather info should be deleted with city (cascade)")
    }

    func testDeleteAllData() {
        // Create multiple cities with weather data
        let city1 = coreDataManager.fetchOrCreateCity(name: "London", cityId: 2643743)
        let city2 = coreDataManager.fetchOrCreateCity(name: "Paris", cityId: 2988507)

        let weatherData: [String: Any] = [
            "weather": [["description": "broken clouds", "icon": "04d"]],
            "main": ["temp": 288.15, "humidity": 72],
            "wind": ["speed": 4.5]
        ]

        coreDataManager.saveWeatherInfo(for: city1, weatherData: weatherData)
        coreDataManager.saveWeatherInfo(for: city2, weatherData: weatherData)

        // Delete all data
        coreDataManager.deleteAllData()

        // Verify all cities are deleted
        let cities = coreDataManager.fetchAllCities()
        XCTAssertTrue(cities.isEmpty, "All cities should be deleted")
    }
}
