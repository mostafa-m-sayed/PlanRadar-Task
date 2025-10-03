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

    var body: some View {
        NavigationView {
            
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color.white, Color(.systemGray4)]),
                               startPoint: .top,
                               endPoint: .bottom)
                .ignoresSafeArea()
                
                
                    VStack {
                        Spacer()
                        Image("Background")
                            .resizable()
                            .scaledToFit()
                            .ignoresSafeArea(edges: .bottom)
                        //                    Text("+")
                    }
                    //                .ignoresSafeArea()
                    
                VStack {
                    HStack {
                        //                    HStack {
                        //                        Spacer()
                        Spacer()
                            Text("CITIES")
                            .font(.headline)
                                .padding(.top, 20)
                        
                        Spacer()
                    }
                    
                    .overlay(
                        HStack {
                            Spacer()
                            Button(action: { showingAddCity.toggle() }) {
                                ZStack {
                                    Color.blue
//                                    Image("Button_right")
//                                        .resizable()
//                                        .scaledToFit()
                                    Text("+")
                                        .fontWeight(.light)
                                        .font(.system(size: 50))
                                        .foregroundColor(.white)
                                        .padding(.trailing, 20)
                                }
                                
                            }
                            .frame(width: 110, height: 60)
                            .cornerRadius(20)
                            .padding(.trailing, -20)
                            .padding(.top, 20)
                            .shadow(radius: 10)
                        }
                    )
                    .padding(.bottom, 20)
//                    .padding(.top, -80)
//                    .padding(.trailing, -250)
//                    .position(x: 0, y: 0)
//                    .allowsHitTesting(true)
//                    .zIndex(10)
//                    .position(x: UIScreen.main.bounds.width - 85,y: 10)
                    
                    
                    List {
                        ForEach(cities) { city in
                            CityRow(city: city)
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                        }
                        .onDelete(perform: deleteCity)
                    }
                    .scrollContentBackground(.hidden)
                    .listStyle(.plain)
                    .listSectionSeparator(.hidden)
                    .listRowInsets(EdgeInsets())
                    .onAppear {
                        loadDummyCities()
                    }
                    //                .padding(.top, 50)
                    
                }
            }
//            .navigationTitle("CITIES")
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbarBackground(.hidden, for: .navigationBar)
            .onAppear {
                let appearance = UINavigationBarAppearance()
                appearance.configureWithTransparentBackground()
                appearance.backgroundColor = .clear
                appearance.shadowColor = .clear
                UINavigationBar.appearance().standardAppearance = appearance
                UINavigationBar.appearance().scrollEdgeAppearance = appearance
            }
            .sheet(isPresented: $showingAddCity) {
                    VStack(spacing: 20) {
                        Text("Add New City")
                            .font(.headline)

                        TextField("City name", text: $newCityName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)

                        HStack {
                            Button("Cancel") {
                                showingAddCity = false
                                newCityName = ""
                            }
                            .foregroundColor(.red)

                            Spacer()

                            Button("Save") {
                                if !newCityName.isEmpty {
                                    addCity(name: newCityName)
                                    newCityName = ""
                                    showingAddCity = false
                                }
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .padding(.horizontal)
                    }
                    .padding()
                    .frame(maxWidth: 300)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.hidden)
                }
        }
    }
    
    
    private func deleteCity(at offsets: IndexSet) {
        offsets.forEach { index in
            let city = cities[index]
            CoreDataManager.shared.deleteCity(city)
        }
        cities.remove(atOffsets: offsets)
    }

    private func addCity(name: String) {
        let weatherService = WeatherService.shared
        weatherService.addCity(name: name) { result in
            switch result {
            case .success:
                // Reload cities from CoreData
                cities = CoreDataManager.shared.fetchAllCities()
            case .failure(let error):
                print("Error adding city: \(error.localizedDescription)")
                // TODO: Show error alert to user
            }
        }
    }

    private func loadDummyCities() {
        // Only load dummy cities if in preview mode and list is empty
        guard isPreview && cities.isEmpty else { return }

        let coreDataManager = CoreDataManager.shared

        // Create dummy cities: London, Vienna, Paris
        let dummyCityNames = ["London", "Vienna", "Paris"]
        let dummyCityIds: [Int64] = [2643743, 2761369, 2988507]

        for (index, cityName) in dummyCityNames.enumerated() {
            // Check if city already exists in CoreData
            if coreDataManager.fetchCity(byName: cityName) == nil {
                _ = coreDataManager.fetchOrCreateCity(name: cityName, cityId: dummyCityIds[index])
            }
        }

        coreDataManager.saveContext()

        // Load cities from CoreData
        cities = coreDataManager.fetchAllCities()
    }
}

#Preview {
    ContentView(isPreview: true).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
