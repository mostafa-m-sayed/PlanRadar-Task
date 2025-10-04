//
//  WeatherRepositorySwiftTests.swift
//  PlanRadar-WeatherApp
//
//  Created by Mostafa Sayed on 04/10/2025.
//


import XCTest
@testable import PlanRadar_WeatherApp

// MARK: - WeatherRepository Tests
final class WeatherRepositoryTests: XCTestCase {
    
    var repository: WeatherRepository!
    var mockNetworkManager: MockNetworkManager!
    
    @MainActor
    override func setUp() async throws {
        try await super.setUp()
        mockNetworkManager = MockNetworkManager()
        repository = WeatherRepository(networkManager: mockNetworkManager)
    }

    @MainActor
    override func tearDown() async throws {
        repository = nil
        mockNetworkManager = nil
        try await super.tearDown()
    }
    
    // MARK: - Helpers
    
    private func createMockWeatherResponse(
        name: String,
        temp: Double,
        humidity: Int,
        windSpeed: Double,
        description: String,
        icon: String
    ) -> WeatherResponse {
        let weather = WeatherDetailsDescription(description: description, icon: icon)
        let main = WeatherMainData(temp: temp, humidity: humidity)
        let wind = WeatherWindDetails(speed: windSpeed)
        
        return WeatherResponse(
            weather: weather,
            main: main,
            wind: wind,
            name: name
        )
    }
    
    // MARK: - Test Cases
    
    // Test 1: Success case - Valid city returns correct weather data
    @MainActor
    func testFetchWeather_WithValidCity_ShouldReturnWeatherData() async throws {
        let mockResponse = createMockWeatherResponse(
            name: "London",
            temp: 293.65,  // 20.5°C
            humidity: 72,
            windSpeed: 4.5,
            description: "broken clouds",
            icon: "04d"
        )
        await mockNetworkManager.setMockData(mockResponse)
        
        let result = try await repository.fetchWeather(for: "London")
        
        XCTAssertEqual(result.name, "London")
        XCTAssertEqual(result.main.temp, 293.65)
        XCTAssertEqual(result.main.humidity, 72)
        XCTAssertEqual(result.wind.speed, 4.5)
        XCTAssertEqual(result.weather.description, "broken clouds")
        XCTAssertEqual(result.weather.icon, "04d")
    }
    
    // Test 2: Empty city name validation
    @MainActor
    func testFetchWeather_WithEmptyCity_ShouldThrowError() async {
        do {
            _ = try await repository.fetchWeather(for: "")
            XCTFail("Should have thrown an error for empty city")
        } catch {
            XCTAssertTrue(error.localizedDescription.contains("empty"))
        }
    }
    
    // Test 3: Whitespace-only city name validation
    @MainActor
    func testFetchWeather_WithWhitespaceCity_ShouldThrowError() async {
        do {
            _ = try await repository.fetchWeather(for: "   ")
            XCTFail("Should have thrown an error for whitespace city")
        } catch {
            XCTAssertTrue(error.localizedDescription.contains("empty"))
        }
    }
    
    // Test 4: Server error handling
    @MainActor
    func testFetchWeather_WithServerError_ShouldThrowError() async {
        await mockNetworkManager.setError(NetworkError.serverError(500))
        
        do {
            _ = try await repository.fetchWeather(for: "London")
            XCTFail("Should have thrown a network error")
        } catch let error as NetworkError {
            if case .serverError(let code) = error {
                XCTAssertEqual(code, 500)
            } else {
                XCTFail("Wrong error type")
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    // Test 5: Decoding error handling
    @MainActor
    func testFetchWeather_WithDecodingError_ShouldThrowError() async {
        await mockNetworkManager.setError(NetworkError.decodingError)
        
        do {
            _ = try await repository.fetchWeather(for: "London")
            XCTFail("Should have thrown a decoding error")
        } catch let error as NetworkError {
            XCTAssertEqual(error, .decodingError)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    // Test 6: Response structure contains all required fields
    @MainActor
    func testFetchWeather_ResponseStructure_ContainsRequiredFields() async throws {
        let mockResponse = createMockWeatherResponse(
            name: "London",
            temp: 293.65,
            humidity: 72,
            windSpeed: 4.5,
            description: "broken clouds",
            icon: "04d"
        )
        await mockNetworkManager.setMockData(mockResponse)
        
        let result = try await repository.fetchWeather(for: "London")
        
        XCTAssertNotNil(result.weather, "Response should contain weather details")
        XCTAssertNotNil(result.main, "Response should contain main weather data")
        XCTAssertNotNil(result.wind, "Response should contain wind data")
        XCTAssertFalse(result.name.isEmpty, "City name should not be empty")
        XCTAssertFalse(result.weather.description.isEmpty, "Weather description should not be empty")
    }
    
    // Test 7: Temperature conversion and formatting
    @MainActor
    func testFetchWeather_TemperatureString_IsFormattedCorrectly() async throws {
        let mockResponse = createMockWeatherResponse(
            name: "London",
            temp: 293.65,  // 20.5°C
            humidity: 72,
            windSpeed: 4.5,
            description: "broken clouds",
            icon: "04d"
        )
        await mockNetworkManager.setMockData(mockResponse)
        
        let result = try await repository.fetchWeather(for: "London")
        
        XCTAssertEqual(result.main.temperatureString, "20.5 ℃")
        XCTAssertEqual(result.main.himidityString, "72 %")
        XCTAssertEqual(result.wind.speedString, "4.5 km/h")
    }
    
    // Test 8: Icon URL generation
    @MainActor
    func testFetchWeather_IconURL_IsValidFormat() async throws {
        let mockResponse = createMockWeatherResponse(
            name: "London",
            temp: 293.65,
            humidity: 72,
            windSpeed: 4.5,
            description: "broken clouds",
            icon: "04d"
        )
        await mockNetworkManager.setMockData(mockResponse)
        
        let result = try await repository.fetchWeather(for: "London")
        
        let expectedURL = "https://openweathermap.org/img/w/04d.png"
        XCTAssertEqual(result.weather.iconURL, expectedURL)
        XCTAssertTrue(result.weather.iconURL.hasPrefix("https://"))
    }
    
    // Test 9: Multiple sequential requests
    @MainActor
    func testFetchWeather_SequentialRequests_ShouldSucceed() async throws {
        
        let londonResponse = createMockWeatherResponse(
            name: "London",
            temp: 293.65,
            humidity: 72,
            windSpeed: 4.5,
            description: "broken clouds",
            icon: "04d"
        )
        
        let parisResponse = createMockWeatherResponse(
            name: "Paris",
            temp: 285.15,
            humidity: 80,
            windSpeed: 5.5,
            description: "light rain",
            icon: "10d"
        )
        
        
        await mockNetworkManager.setMockData(londonResponse)
        let result1 = try await repository.fetchWeather(for: "London")
        
        await mockNetworkManager.setMockData(parisResponse)
        let result2 = try await repository.fetchWeather(for: "Paris")
        
        
        XCTAssertEqual(result1.name, "London")
        XCTAssertEqual(result1.main.temperatureString, "20.5 ℃")
        XCTAssertEqual(result2.name, "Paris")
        XCTAssertEqual(result2.main.temperatureString, "12.0 ℃")
    }
    
    // Test 10: Data validation - valid ranges
    @MainActor
    func testFetchWeather_DataValidation_ValuesInValidRange() async throws {
        
        let mockResponse = createMockWeatherResponse(
            name: "London",
            temp: 293.65,
            humidity: 72,
            windSpeed: 4.5,
            description: "broken clouds",
            icon: "04d"
        )
        await mockNetworkManager.setMockData(mockResponse)
        
        
        let result = try await repository.fetchWeather(for: "London")
        
        
        // Temperature validation
        let celsius = result.main.temp - 273.15
        XCTAssertTrue(celsius > -90 && celsius < 60, "Temperature should be in reasonable range")
        
        // Humidity validation
        XCTAssertTrue(result.main.humidity >= 0 && result.main.humidity <= 100,
                     "Humidity should be between 0 and 100")
        
        // Wind speed validation
        XCTAssertTrue(result.wind.speed >= 0, "Wind speed should be non-negative")
    }
}
