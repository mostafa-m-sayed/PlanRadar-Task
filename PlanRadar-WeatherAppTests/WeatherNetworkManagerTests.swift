//
//  WeatherNetworkManagerTests.swift
//  PlanRadar-WeatherAppTests
//

import XCTest
@testable import PlanRadar_WeatherApp

final class WeatherNetworkManagerTests: XCTestCase {

    var networkManager: WeatherNetworkManager!
    var mockRepository: MockRepository!

    override func setUp() {
        super.setUp()

        // Create mock JSON responses
        let londonJSON = """
        {
            "coord": {"lon": -0.1257, "lat": 51.5085},
            "weather": [{"id": 803, "main": "Clouds", "description": "broken clouds", "icon": "04d"}],
            "base": "stations",
            "main": {"temp": 288.15, "feels_like": 287.5, "temp_min": 286.15, "temp_max": 290.15, "pressure": 1013, "humidity": 72},
            "visibility": 10000,
            "wind": {"speed": 4.5, "deg": 230},
            "clouds": {"all": 75},
            "dt": 1696348800,
            "sys": {"type": 2, "id": 2019646, "country": "GB", "sunrise": 1696310400, "sunset": 1696353600},
            "timezone": 3600,
            "id": 2643743,
            "name": "London",
            "cod": 200
        }
        """.data(using: .utf8)!

        let viennaJSON = """
        {
            "coord": {"lon": 16.3721, "lat": 48.2083},
            "weather": [{"id": 800, "main": "Clear", "description": "clear sky", "icon": "01d"}],
            "base": "stations",
            "main": {"temp": 293.15, "feels_like": 292.5, "temp_min": 291.15, "temp_max": 295.15, "pressure": 1015, "humidity": 65},
            "visibility": 10000,
            "wind": {"speed": 3.5, "deg": 180},
            "clouds": {"all": 0},
            "dt": 1696348800,
            "sys": {"type": 2, "id": 2012516, "country": "AT", "sunrise": 1696310400, "sunset": 1696353600},
            "timezone": 7200,
            "id": 2761369,
            "name": "Vienna",
            "cod": 200
        }
        """.data(using: .utf8)!

        let parisJSON = """
        {
            "coord": {"lon": 2.3488, "lat": 48.8534},
            "weather": [{"id": 500, "main": "Rain", "description": "light rain", "icon": "10d"}],
            "base": "stations",
            "main": {"temp": 285.15, "feels_like": 284.5, "temp_min": 283.15, "temp_max": 287.15, "pressure": 1010, "humidity": 80},
            "visibility": 8000,
            "wind": {"speed": 5.5, "deg": 270},
            "clouds": {"all": 90},
            "rain": {"1h": 0.5},
            "dt": 1696348800,
            "sys": {"type": 2, "id": 2041230, "country": "FR", "sunrise": 1696310400, "sunset": 1696353600},
            "timezone": 7200,
            "id": 2988507,
            "name": "Paris",
            "cod": 200
        }
        """.data(using: .utf8)!

        let iconData = Data(base64Encoded: "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==")!

        // Map URLs to mock responses
        let mockResponses: [String: Data] = [
            "https://api.openweathermap.org/data/2.5/weather?q=London&appid=f5cb0b965ea1564c50c6f1b74534d823": londonJSON,
            "https://api.openweathermap.org/data/2.5/weather?q=Vienna&appid=f5cb0b965ea1564c50c6f1b74534d823": viennaJSON,
            "https://api.openweathermap.org/data/2.5/weather?q=Paris&appid=f5cb0b965ea1564c50c6f1b74534d823": parisJSON,
            "http://openweathermap.org/img/w/10d.png": iconData,
            "http://openweathermap.org/img/w/04d.png": iconData,
            "http://openweathermap.org/img/w/01d.png": iconData
        ]

        mockRepository = MockRepository(mockResponses: mockResponses)
        networkManager = WeatherNetworkManager(repository: mockRepository)
    }

    override func tearDown() {
        networkManager = nil
        mockRepository = nil
        super.tearDown()
    }

    // MARK: - Singleton Tests

    func testSharedManagerReturnsSameInstance() {
        let manager1 = WeatherNetworkManager.shared()
        let manager2 = WeatherNetworkManager.shared()

        XCTAssertTrue(manager1 === manager2, "Shared manager should return the same instance")
    }

    // MARK: - Weather Fetch Tests

    func testFetchWeatherForValidCity() {
        let expectation = expectation(description: "Fetch weather for London")

        networkManager.fetchWeather(forCity: "London") { weatherData, error in
            XCTAssertNil(error, "Error should be nil for valid city")
            XCTAssertNotNil(weatherData, "Weather data should not be nil")

            if let weatherData = weatherData {
                XCTAssertNotNil(weatherData["weather"], "Response should contain weather array")
                XCTAssertNotNil(weatherData["main"], "Response should contain main object")
                XCTAssertNotNil(weatherData["wind"], "Response should contain wind object")

                if let main = weatherData["main"] as? [String: Any] {
                    XCTAssertNotNil(main["temp"], "Main should contain temperature")
                    XCTAssertNotNil(main["humidity"], "Main should contain humidity")
                }

                if let wind = weatherData["wind"] as? [String: Any] {
                    XCTAssertNotNil(wind["speed"], "Wind should contain speed")
                }

                if let weather = weatherData["weather"] as? [[String: Any]], !weather.isEmpty {
                    let weatherItem = weather[0]
                    XCTAssertNotNil(weatherItem["description"], "Weather should contain description")
                }
            }

            expectation.fulfill()
        }

        waitForExpectations(timeout: 1.0) { error in
            if let error = error {
                XCTFail("Timeout error: \(error)")
            }
        }
    }

    func testFetchWeatherForVienna() {
        let expectation = expectation(description: "Fetch weather for Vienna")

        networkManager.fetchWeather(forCity: "Vienna") { weatherData, error in
            XCTAssertNil(error, "Error should be nil for valid city")
            XCTAssertNotNil(weatherData, "Weather data should not be nil")
            XCTAssertNotNil(weatherData?["name"], "Response should contain city name")

            expectation.fulfill()
        }

        waitForExpectations(timeout: 1.0)
    }

    func testFetchWeatherForParis() {
        let expectation = expectation(description: "Fetch weather for Paris")

        networkManager.fetchWeather(forCity: "Paris") { weatherData, error in
            XCTAssertNil(error, "Error should be nil for valid city")
            XCTAssertNotNil(weatherData, "Weather data should not be nil")

            expectation.fulfill()
        }

        waitForExpectations(timeout: 1.0)
    }

    func testFetchWeatherForInvalidCity() {
        let expectation = expectation(description: "Fetch weather for invalid city")

        networkManager.fetchWeather(forCity: "InvalidCityNameThatDoesNotExist123456") { weatherData, error in
            XCTAssertNotNil(error, "Error should not be nil for invalid city")
            XCTAssertNil(weatherData, "Weather data should be nil for invalid city")

            expectation.fulfill()
        }

        waitForExpectations(timeout: 1.0)
    }

    func testFetchWeatherForEmptyString() {
        let expectation = expectation(description: "Fetch weather for empty string")

        networkManager.fetchWeather(forCity: "") { weatherData, error in
            XCTAssertNotNil(error, "Error should not be nil for empty city name")
            XCTAssertNil(weatherData, "Weather data should be nil for empty city name")

            if let error = error as NSError? {
                XCTAssertEqual(error.code, -1, "Error code should be -1 for empty city name")
            }

            expectation.fulfill()
        }

        waitForExpectations(timeout: 1.0)
    }

    // MARK: - Icon Fetch Tests

    func testFetchWeatherIconWithValidId() {
        let expectation = expectation(description: "Fetch weather icon")

        // Using a common icon ID (10d = day rain)
        networkManager.fetchWeatherIcon(withId: "10d") { imageData, error in
            XCTAssertNil(error, "Error should be nil for valid icon ID")
            XCTAssertNotNil(imageData, "Image data should not be nil")

            if let imageData = imageData {
                XCTAssertTrue(imageData.count > 0, "Image data should have content")
            }

            expectation.fulfill()
        }

        waitForExpectations(timeout: 1.0) { error in
            if let error = error {
                XCTFail("Timeout error: \(error)")
            }
        }
    }

    func testFetchWeatherIconWithEmptyId() {
        let expectation = expectation(description: "Fetch icon with empty ID")

        networkManager.fetchWeatherIcon(withId: "") { imageData, error in
            XCTAssertNotNil(error, "Error should not be nil for empty icon ID")
            XCTAssertNil(imageData, "Image data should be nil for empty icon ID")

            if let error = error as NSError? {
                XCTAssertEqual(error.code, -1, "Error code should be -1 for empty icon ID")
            }

            expectation.fulfill()
        }

        waitForExpectations(timeout: 1.0)
    }

    // MARK: - Response Structure Tests

    func testWeatherResponseContainsRequiredFields() {
        let expectation = expectation(description: "Verify response structure")

        networkManager.fetchWeather(forCity: "London") { weatherData, error in
            if let error = error {
                XCTFail("Request failed with error: \(error)")
                expectation.fulfill()
                return
            }

            guard let weatherData = weatherData else {
                XCTFail("Weather data is nil")
                expectation.fulfill()
                return
            }

            // Verify weather array
            XCTAssertTrue(weatherData["weather"] is [Any], "weather should be an array")
            if let weather = weatherData["weather"] as? [[String: Any]] {
                XCTAssertTrue(!weather.isEmpty, "weather array should not be empty")
                if !weather.isEmpty {
                    let weatherItem = weather[0]
                    XCTAssertTrue(weatherItem["description"] is String, "description should be a string")
                }
            }

            // Verify main object
            XCTAssertTrue(weatherData["main"] is [String: Any], "main should be a dictionary")
            if let main = weatherData["main"] as? [String: Any] {
                XCTAssertTrue(main["temp"] is NSNumber, "temp should be a number")
                XCTAssertTrue(main["humidity"] is NSNumber, "humidity should be a number")
            }

            // Verify wind object
            XCTAssertTrue(weatherData["wind"] is [String: Any], "wind should be a dictionary")
            if let wind = weatherData["wind"] as? [String: Any] {
                XCTAssertTrue(wind["speed"] is NSNumber, "speed should be a number")
            }

            expectation.fulfill()
        }

        waitForExpectations(timeout: 1.0)
    }

    // MARK: - Concurrency Tests

    func testMultipleConcurrentRequests() {
        let expectation1 = expectation(description: "Fetch London")
        let expectation2 = expectation(description: "Fetch Vienna")
        let expectation3 = expectation(description: "Fetch Paris")

        networkManager.fetchWeather(forCity: "London") { weatherData, error in
            XCTAssertNil(error)
            XCTAssertNotNil(weatherData)
            expectation1.fulfill()
        }

        networkManager.fetchWeather(forCity: "Vienna") { weatherData, error in
            XCTAssertNil(error)
            XCTAssertNotNil(weatherData)
            expectation2.fulfill()
        }

        networkManager.fetchWeather(forCity: "Paris") { weatherData, error in
            XCTAssertNil(error)
            XCTAssertNotNil(weatherData)
            expectation3.fulfill()
        }

        waitForExpectations(timeout: 1.0)
    }

    // MARK: - Temperature Conversion Tests

    func testTemperatureDataIsValid() {
        let expectation = expectation(description: "Verify temperature is valid")

        networkManager.fetchWeather(forCity: "London") { weatherData, error in
            XCTAssertNil(error)

            if let main = weatherData?["main"] as? [String: Any],
               let temp = main["temp"] as? Double {
                // Temperature in Kelvin should be above absolute zero
                XCTAssertTrue(temp > 0, "Temperature should be above absolute zero")

                // Convert to Celsius
                let celsius = temp - 273.15

                // Reasonable temperature range for Earth (-90 to 60)
                XCTAssertTrue(celsius > -90 && celsius < 60, "Temperature should be in reasonable range")
            }

            expectation.fulfill()
        }

        waitForExpectations(timeout: 1.0)
    }

    // MARK: - Humidity Tests

    func testHumidityDataIsValid() {
        let expectation = expectation(description: "Verify humidity is valid")

        networkManager.fetchWeather(forCity: "London") { weatherData, error in
            XCTAssertNil(error)

            if let main = weatherData?["main"] as? [String: Any],
               let humidity = main["humidity"] as? Int {
                // Humidity should be between 0 and 100
                XCTAssertTrue(humidity >= 0 && humidity <= 100, "Humidity should be between 0 and 100")
            }

            expectation.fulfill()
        }

        waitForExpectations(timeout: 1.0)
    }

    // MARK: - Wind Speed Tests

    func testWindSpeedDataIsValid() {
        let expectation = expectation(description: "Verify wind speed is valid")

        networkManager.fetchWeather(forCity: "London") { weatherData, error in
            XCTAssertNil(error)

            if let wind = weatherData?["wind"] as? [String: Any],
               let speed = wind["speed"] as? Double {
                // Wind speed should be non-negative
                XCTAssertTrue(speed >= 0, "Wind speed should be non-negative")
            }

            expectation.fulfill()
        }

        waitForExpectations(timeout: 1.0)
    }

    // MARK: - Error Handling Tests

    func testMockErrorHandling() {
        let expectation = expectation(description: "Test error handling")

        let error = NSError(domain: "TestError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Mock error"])
        mockRepository.mockError = error

        networkManager.fetchWeather(forCity: "London") { weatherData, error in
            XCTAssertNotNil(error, "Error should not be nil when mock is set to return error")
            XCTAssertNil(weatherData, "Weather data should be nil when error occurs")

            expectation.fulfill()
        }

        waitForExpectations(timeout: 1.0)
    }

    func testMissingMockData() {
        let expectation = expectation(description: "Test missing mock data")

        networkManager.fetchWeather(forCity: "InvalidCityNameThatDoesNotExist123456") { weatherData, error in
            XCTAssertNotNil(error, "Error should not be nil for unmocked URL")
            XCTAssertNil(weatherData, "Weather data should be nil for unmocked URL")

            expectation.fulfill()
        }

        waitForExpectations(timeout: 1.0)
    }
}
