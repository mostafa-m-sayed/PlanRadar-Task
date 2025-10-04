//
//  ContentView.swift
//  PlanRadar-WeatherApp
//
//  Created by Mostafa Sayed on 03/10/2025.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @State private var cities: [City] = []
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var showingAddCity = false
    @State private var newCityName = ""
    
    var isPreview: Bool = false
    private let viewModel = WeatherViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                BackgroundView()

                VStack {
                    HeaderView(onAddTap: {
                        showingAddCity.toggle()
                    })
                    
                    CitiesListView(
                        cities: cities,
                        onDelete: deleteCity
                    )
                    .onAppear {
                        loadCities()
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
    
    private func deleteCity(at offsets: IndexSet) {
        offsets.forEach { index in
            let city = cities[index]
            CoreDataManager.shared.deleteCity(city)
        }
        cities.remove(atOffsets: offsets)
    }
    
    private func addCity(name: String) {
        viewModel.saveCity(name: name)
        cities = CoreDataManager.shared.fetchAllCities()
    }
    
    private func loadCities() {
        if isPreview {
            #if DEBUG
            loadDummyCities()
            #endif
        } else {
            cities = CoreDataManager.shared.fetchAllCities()
        }
    }

    #if DEBUG
    private func loadDummyCities() {
        guard cities.isEmpty else { return }
        
        let coreDataManager = CoreDataManager.shared
        let dummyCityNames = ["London", "Vienna", "Paris"]
        let dummyCityIds: [Int64] = [2643743, 2761369, 2988507]
        
        for (index, cityName) in dummyCityNames.enumerated() {
            if coreDataManager.fetchCity(byName: cityName) == nil {
                _ = coreDataManager.fetchOrCreateCity(
                    name: cityName,
                    cityId: dummyCityIds[index]
                )
            }
        }
        
        coreDataManager.saveContext()
        cities = coreDataManager.fetchAllCities()
    }
    #endif

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
