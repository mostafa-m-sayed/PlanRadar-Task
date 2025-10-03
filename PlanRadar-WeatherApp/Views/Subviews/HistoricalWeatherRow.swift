//
//  HistoricalWeatherRow.swift
//  PlanRadar-WeatherApp
//
//  Created by Mostafa Sayed on 03/10/2025.
//

import SwiftUI
struct HistoricalWeatherRow: View {
    let weather: WeatherResponse
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("5/8/1992")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.3))
            
            Text("\(weather.weather.description), \(weather.main.temperatureString)")
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(Color(red: 0.25, green: 0.55, blue: 0.75))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 10)
        .listRowBackground(Color.clear)
    }
}
