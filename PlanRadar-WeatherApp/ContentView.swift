//
//  ContentView.swift
//  PlanRadar-WeatherApp
//
//  Created by Mostafa Sayed on 03/10/2025.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @State private var showingAddCity = false
    @State private var newCityName = ""

    var isPreview: Bool = false
    @StateObject private var viewModel = WeatherViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                BackgroundView()

                VStack {
                    HeaderView(onAddTap: {
                        showingAddCity.toggle()
                    })
                    .font(.system(size: 40))
                    CitiesListView(
                        cities: viewModel.cities,
                        onDelete: viewModel.deleteCity
                    )
                    .onAppear {
                        viewModel.loadCities(isPreview: isPreview)
                    }
                }
            }
            .onAppear {
                configureNavigationBarAppearance()
            }
            .sheet(isPresented: $showingAddCity) {
                AddCitySheet(
                    isPresented: $showingAddCity,
                    cityName: $newCityName,
                    onSave: addCity
                )
            }
        }
    }
    
    // MARK: - Private Methods

    private func addCity(name: String) {
        viewModel.saveCity(name: name)
    }

    private func configureNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = .clear
        appearance.shadowColor = .clear
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
}

#Preview {
    ContentView(isPreview: true)
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
