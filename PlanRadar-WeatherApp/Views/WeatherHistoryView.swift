//
//  WeatherHistoryView.swift
//  PlanRadar-WeatherApp
//
//  Created by Mostafa Sayed on 03/10/2025.
//

import SwiftUI

struct WeatherHistoryView: View {
    var city: City
    
    var body: some View {
        VStack {
            Text("Details about \(city.name)")
                .font(.title)
                .padding()
            Spacer()
        }
        .navigationTitle(city.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}
