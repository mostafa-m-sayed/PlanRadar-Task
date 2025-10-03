//
//  WeatherResponse.swift
//  PlanRadar-WeatherApp
//
//  Created by Mostafa Sayed on 03/10/2025.
//

struct WeatherResponse: Codable {
    let weather: WeatherDetailsDescription
    let main: WeatherMainData
    let wind: WeatherWindDetails

    private enum CodingKeys: String, CodingKey {
        case weather
        case main
        case wind
    }

    init(weather: WeatherDetailsDescription, main: WeatherMainData, wind: WeatherWindDetails) {
        self.weather = weather
        self.main = main
        self.wind = wind
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // OpenWeather returns `weather` as an array; we take the first entry
        var weatherArray = try container.nestedUnkeyedContainer(forKey: .weather)
        let firstWeather = try weatherArray.decode(WeatherDetailsDescription.self)
        self.weather = firstWeather

        self.main = try container.decode(WeatherMainData.self, forKey: .main)
        self.wind = try container.decode(WeatherWindDetails.self, forKey: .wind)
    }
}
