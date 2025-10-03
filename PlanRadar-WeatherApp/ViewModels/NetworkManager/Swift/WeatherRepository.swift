//
//  WeatherRepository.swift
//  PlanRadar-WeatherApp
//
//  Created by Mostafa Sayed on 03/10/2025.
//

import Foundation

class WeatherRepository {
    let baseUrl = "https://api.openweathermap.org/data/2.5/weather"
    let apiKey = "f5cb0b965ea1564c50c6f1b74534d823"
    let urlSession = URLSession.shared
    
    func fetchWeather(for city: String) async throws -> WeatherResponse {
        guard !city.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw NSError(domain: "WeatherRepository", code: -1, userInfo: [NSLocalizedDescriptionKey: "City name cannot be empty"])
        }

        var components = URLComponents(string: baseUrl)
        components?.queryItems = [
            URLQueryItem(name: "q", value: city),
            URLQueryItem(name: "appid", value: apiKey)
        ]

        guard let url = components?.url else {
            throw NSError(domain: "WeatherRepository", code: -2, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }

        let (data, _) = try await urlSession.data(for: URLRequest(url: url))
        let decoder = JSONDecoder()
        return try decoder.decode(WeatherResponse.self, from: data)
    }
    
}
