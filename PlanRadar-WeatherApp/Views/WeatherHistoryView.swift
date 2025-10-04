//
//  WeatherHistoryView.swift
//  PlanRadar-WeatherApp
//
//  Created by Mostafa Sayed on 03/10/2025.
//

import SwiftUI

struct WeatherHistoryView: View {
    let city: City
    @Environment(\.dismiss) var dismiss
    
    @State private var weatherHistory: [WeatherResponse] = [
        WeatherResponse(weather: WeatherDetailsDescription(description: "Hot", icon: "10d"), main: WeatherMainData(temp: 299, humidity: 7), wind: WeatherWindDetails(speed: 22)),
        WeatherResponse(weather: WeatherDetailsDescription(description: "Rainy", icon: "10d"), main: WeatherMainData(temp: 315, humidity: 18), wind: WeatherWindDetails(speed: 3.5)),
        WeatherResponse(weather: WeatherDetailsDescription(description: "Cloudy", icon: "10d"), main: WeatherMainData(temp: 330, humidity: 80), wind: WeatherWindDetails(speed: 6))
    ]
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.white, Color(.systemGray4)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack {
                Spacer()
                Image("Background")
                    .resizable()
                    .scaledToFit()
                    .ignoresSafeArea(edges: .bottom)
            }
            .ignoresSafeArea()

            
            VStack(spacing: 0) {
                
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                            .background(Color(red: 0.25, green: 0.55, blue: 0.75))
                            .cornerRadius(12)
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 2) {
                        Text(city.name?.uppercased() ?? "")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.3))
                            .tracking(2)
                        
                        Text("HISTORICAL")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.3))
                            .tracking(2)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 30)
                
                List {
                    ForEach(Array(weatherHistory.enumerated()), id: \.offset) { _, weather in
                        HistoricalWeatherRow(weather: weather)
                    }
                }
                .scrollContentBackground(.hidden)
                .listStyle(.plain)
                .listSectionSeparator(.hidden)
                .padding(.horizontal, 20)
                
                Spacer()
            }
        }
        .navigationBarHidden(true)
        .task {
            let history = CoreDataManager.shared.fetchWeatherHistory(for: city)
            if !history.isEmpty {
                weatherHistory = history
            }
        }
    }
}

