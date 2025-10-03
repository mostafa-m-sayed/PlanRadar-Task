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
                    Text("+")
                }
                .ignoresSafeArea()

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

                VStack {
                    HStack {
                        Spacer()
                        Button(action: { showingAddCity = true }) {
                            Image("Button_right")
                                .resizable()
                                .scaledToFit()
                        }
                        .padding(.trailing, -40)
    //                    .padding(.top, 10)
                        .padding(.top, 0)
                        .frame(width: 150, height: 150)
                    }
                    Spacer()
                }
                .padding(.top, -80)
//                .position(x: -50,y: 50)

            }
            .navigationTitle("CITIES")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
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
    //                                cities.append(City(name: newCityName))
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
        cities.remove(atOffsets: offsets)
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
