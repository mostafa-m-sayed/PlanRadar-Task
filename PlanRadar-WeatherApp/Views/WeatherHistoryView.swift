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
    @StateObject private var viewModel = WeatherViewModel()
    
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
                    ForEach(viewModel.weatherHistory, id: \.objectID) { weatherInfo in
                        HistoricalWeatherRow(weatherInfo: weatherInfo)
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
            viewModel.loadWeatherHistory(for: city)
        }
    }
}

