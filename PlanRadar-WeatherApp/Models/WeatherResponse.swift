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
}
