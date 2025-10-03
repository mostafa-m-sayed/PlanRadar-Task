//
//  ContentView.swift
//  PlanRadar-WeatherApp
//
//  Created by Mostafa Sayed on 03/10/2025.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @State private var cities: [City] = [
        City(name: "London"),
        City(name: "Paris"),
        City(name: "Vienna")
    ]
    
    @State private var showingAddCity = false
    @State private var newCityName = ""
    
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
                }
                .ignoresSafeArea()
                
                List {
                    ForEach(cities) { city in
                        CityRow(city: city)
                    }
                    .onDelete(perform: deleteCity)
                }
                .scrollContentBackground(.hidden)
                .listStyle(.plain)
                .listSectionSeparator(.hidden)
                
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("CITIES")
                        .font(.headline)
                        .tracking(2)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddCity = true }) {
                        Image("Button_right")
                            .resizable()
                            .scaledToFit()
                        //                                .frame(width: 44, height: 32)
                    }
                }
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
                                cities.append(City(name: newCityName))
                                newCityName = ""
                                showingAddCity = false
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding(.horizontal)
                }
                .padding()
                .frame(maxWidth: 300) // 👈 limits width
                .presentationDetents([.medium]) // 👈 makes it appear like a centered card
                .presentationDragIndicator(.hidden)
            }
        }
    }
    
    private func deleteCity(at offsets: IndexSet) {
        cities.remove(atOffsets: offsets)
    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
