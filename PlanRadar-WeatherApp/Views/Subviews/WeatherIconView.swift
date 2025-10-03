//
//  WeatherIconView.swift
//  PlanRadar-WeatherApp
//
//  Created by Mostafa Sayed on 03/10/2025.
//

import SwiftUI

struct WeatherIconView: View {
    let iconURL: String
    
    var body: some View {
        AsyncImage(url: URL(string: iconURL)) { phase in
            switch phase {
            case .empty:
                ProgressView()
            case .success(let image):
                image
                    .resizable()
                    .scaledToFit()
            case .failure:
                Image(systemName: "cloud.sun.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(Color(red: 0.25, green: 0.55, blue: 0.75))
            @unknown default:
                EmptyView()
            }
        }
    }
}
