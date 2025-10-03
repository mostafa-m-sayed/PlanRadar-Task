//
//  CityWeatherView.swift
//  PlanRadar-WeatherApp
//
//  Created by Mostafa Sayed on 03/10/2025.
//

import SwiftUI

struct CityWeatherView: View {
    let city: City
    @ObservedObject var viewModel = WeatherViewModel()
    @Environment(\.dismiss) var dismiss
    
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
                HStack { // Title view
                    Button(action: {
                        dismiss()
                    }) {
                        ZStack {
                            Image("Button_left")
                            Image(systemName: "chevron.left")
                                .font(.system(size: 20, weight: .medium))
//                                .background(Color(red: 0.25, green: 0.55, blue: 0.75))
                                .foregroundColor(.white)
                                
                                
                        }
                        
//                            .font(.system(size: 20, weight: .medium))
//                            .foregroundColor(.white)
//                            .frame(width: 40, height: 40)
//                            .background(Color(red: 0.25, green: 0.55, blue: 0.75))
//                            .cornerRadius(12)
                    }
                    
                    Spacer()
                    
                    Text(city.name.uppercased())
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.3))
                        .tracking(2)
                    
                    Spacer()
                    
                }
//                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                Spacer()
                
                VStack(spacing: 0) { // Card container
                    WeatherIconView(iconURL: viewModel.weatherData?.weather.iconURL ?? "")
                        .frame(width: 100, height: 100)
                        .padding(.top, 20)
                        .padding(.bottom, 10)
                    
                    VStack(spacing: 18) {
                        WeatherRow(label: "DESCRIPTION", value: viewModel.weatherData?.weather.description ?? "")
                        WeatherRow(label: "TEMPERATURE", value: viewModel.weatherData?.main.temperatureString ?? "")
                        WeatherRow(label: "HUMIDITY", value: viewModel.weatherData?.main.himidityString ?? "")
                        WeatherRow(label: "WINDSPEED", value: viewModel.weatherData?.wind.speedString ?? "")
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 45)
                }
                .background(
                    RoundedRectangle(cornerRadius: 35)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.08), radius: 15, x: 0, y: 8)
                )
                .padding(.horizontal, 30)
                
                Spacer()
                
                VStack(spacing: 4) { // Footer view
                    Text("WEATHER INFORMATION FOR \(city.name.uppercased()) RECEIVED ON")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.4))
                        .tracking(0.5)
                    
                    Text("03.10.2025 - 11:28")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.4))
                        .tracking(0.5)
                }
                .padding(.bottom, 40)
            }
        }
        .navigationBarHidden(true)
    }
}

struct WeatherRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.3))
                .tracking(1)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(Color(red: 0.25, green: 0.55, blue: 0.75))
        }
    }
}
