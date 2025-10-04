import SwiftUI
import CoreData

struct CitiesListView: View {
    let cities: [City]
    let onDelete: (IndexSet) -> Void
    
    var body: some View {
        List {
            ForEach(cities) { city in
                CityRow(city: city)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
            }
            .onDelete(perform: onDelete)
        }
        .scrollContentBackground(.hidden)
        .listStyle(.plain)
        .listSectionSeparator(.hidden)
        .listRowInsets(EdgeInsets())
    }
}

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
//                Image(systemName: "chevron.right")
//                    .foregroundColor(.blue)
            }

            .accentColor(.blue)
            .padding(.vertical, 8)
            .listRowBackground(Color.clear)
        }
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    let sampleCities: [City] = {
        let london = City(context: context)
        london.name = "London"
        london.cityId = 2643743

        let vienna = City(context: context)
        vienna.name = "Vienna"
        vienna.cityId = 2761369

        let paris = City(context: context)
        paris.name = "Paris"
        paris.cityId = 2988507

        return [london, vienna, paris]
    }()

    return CitiesListView(
        cities: sampleCities,
        onDelete: { _ in }
    )
    .environment(\.managedObjectContext, context)
}
