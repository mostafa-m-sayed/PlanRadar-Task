//  CityWeatherView.swift
//  PlanRadar-WeatherApp
//
//  Created by Mostafa Sayed on 03/10/2025.
//

import SwiftUI
import CoreData

struct CityWeatherView: View {
    let city: City
    @ObservedObject var viewModel = WeatherViewModel()
    @Environment(\.dismiss) var dismiss
    @State private var showError = false
    
    @ViewBuilder
    private var weatherDetailsSection: some View {
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
            Text("WEATHER INFORMATION FOR \(city.name?.uppercased() ?? "") RECEIVED ON")
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
    
    @ViewBuilder
    private var loadingOverlay: some View {
        if viewModel.isLoading {
            Color.black.opacity(0.25)
                .ignoresSafeArea()
            ProgressView()
                .tint(Color(red: 0.25, green: 0.55, blue: 0.75))
                .scaleEffect(1.2)
        }
    }
    
    var body: some View {
        ZStack {
            BackgroundView()

            VStack(spacing: 0) { // Title view
                HeaderView(onAddTap: {
                    dismiss()
                },  addButtonOnLeft: true, imageName: "chevron.left", header: city.name ?? "")
                .padding(.top, 20)
                .font(.system(size: 20))
                Spacer()
                
                weatherDetailsSection
            }
            
            loadingOverlay
        }
        .navigationBarHidden(true)
        .task {
            guard let cityName = city.name else { return }
            await viewModel.fetchWeather(for: cityName)
            let dictionary = viewModel.weatherData?.toDictionary() ?? [:]
            CoreDataManager.shared.saveWeatherInfo(for: city, weatherData: dictionary)
        }
        .onChange(of: viewModel.errorMessage) { newValue in
            showError = newValue != nil
        }
        .alert("Error", isPresented: $showError) {
            Button("OK") { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "Something went wrong")
        }
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

#Preview {
    // Use the shared CoreDataManager context for preview
    let coreDataManager = CoreDataManager.shared
    let city = coreDataManager.fetchOrCreateCity(name: "London", cityId: 2643743)
    coreDataManager.saveContext()

    return CityWeatherView(city: city)
        .environment(\.managedObjectContext, coreDataManager.context)
}
