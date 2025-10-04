import SwiftUI

struct HeaderView: View {
    let onAddTap: () -> Void
    
    var body: some View {
        HStack {
            Spacer()
            Text("CITIES")
                .font(.headline)
                .padding(.top, 20)
            Spacer()
        }
        .overlay(
            HStack {
                Spacer()
                AddCityButton(action: onAddTap)
            }
        )
        .padding(.bottom, 20)
    }
}

private struct AddCityButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Color.blue
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
}

#Preview {
    HeaderView(onAddTap: {})
}