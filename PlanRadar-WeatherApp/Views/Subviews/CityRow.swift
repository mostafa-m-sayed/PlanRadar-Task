//
//  CityRow.swift
//  PlanRadar-WeatherApp
//
//  Created by Mostafa Sayed on 03/10/2025.
//

import SwiftUI

struct CityRow: View {
    let city: City   // or you can pass name/country separately
    @State private var showHistory = false

    var body: some View {
        NavigationLink(destination: CityWeatherView(city: city)) {
            HStack {
                Text(city.name ?? "")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
                
                Spacer()
                Button(action: {
                    showHistory = true
                }) {
                    Image(systemName: "info.circle")
                        .foregroundColor(.blue)
                }
                .buttonStyle(.plain) // prevents button styling bubble
                .sheet(isPresented: $showHistory) {
                    NavigationStack {
                        WeatherHistoryView(city: city)
                    }
                }
                Image(systemName: "chevron.right")
                    .foregroundColor(.blue)
            }
            .padding(.vertical, 8)
            .listRowBackground(Color.clear)
        }
    }
}
