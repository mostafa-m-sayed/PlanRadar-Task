import SwiftUI

struct AddCitySheet: View {
    @Binding var isPresented: Bool
    @Binding var cityName: String
    let onSave: (String) -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Add New City")
                .font(.headline)
            
            TextField("City name", text: $cityName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .foregroundColor(.red)
                
                Spacer()
                
                Button("Save") {
                    save()
                }
                .buttonStyle(.borderedProminent)
                .disabled(cityName.isEmpty)
            }
            .padding(.horizontal)
        }
        .padding()
        .frame(maxWidth: 300)
        .presentationDetents([.medium])
        .presentationDragIndicator(.hidden)
    }
    
    private func dismiss() {
        cityName = ""
        isPresented = false
    }
    
    private func save() {
        guard !cityName.isEmpty else { return }
        onSave(cityName)
        cityName = ""
        isPresented = false
    }
}

#Preview {
    AddCitySheet(
        isPresented: .constant(true),
        cityName: .constant(""),
        onSave: { _ in }
    )
}