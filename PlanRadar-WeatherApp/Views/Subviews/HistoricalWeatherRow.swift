//
//  HistoricalWeatherRow.swift
//  PlanRadar-WeatherApp
//
//  Created by Mostafa Sayed on 03/10/2025.
//

import SwiftUI

struct HistoricalWeatherRow: View {
    let weatherInfo: WeatherInfo

    private var formattedDate: String {
        guard let date = weatherInfo.requestDate else { return "N/A" }
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private var temperatureString: String {
        String(format: "%.1f°C", weatherInfo.temperature)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(formattedDate)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.3))

            Text("\(weatherInfo.weatherDescription ?? "N/A"), \(temperatureString)")
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(Color(red: 0.25, green: 0.55, blue: 0.75))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 10)
        .listRowBackground(Color.clear)
    }
}
