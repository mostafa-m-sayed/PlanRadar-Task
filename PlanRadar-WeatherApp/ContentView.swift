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
//        City(name: "London"),
//        City(name: "Paris"),
//        City(name: "Vienna")
    ]
    
    @State private var showingAddCity = false
    @State private var newCityName = ""
    
    var body: some View {
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

            VStack {
                HStack {
                    Spacer()
                    Button(action: { showingAddCity = true }) {
                        Image("Button_right")
                            .resizable()
                            .scaledToFit()
                    }
                    .padding(.trailing, -10)
                    .padding(.top, 10)
                    .frame(width: 100, height: 100)
                }
                Spacer()
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
    
    
    private func deleteCity(at offsets: IndexSet) {
        cities.remove(atOffsets: offsets)
    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
