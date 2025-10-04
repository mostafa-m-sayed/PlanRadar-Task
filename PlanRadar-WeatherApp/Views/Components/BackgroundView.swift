import SwiftUI

struct BackgroundView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.white, Color(.systemGray4)]),
                startPoint: .top,
                endPoint: .bottom
            )
            
            VStack {
                Spacer()
                Image("Background")
                    .resizable()
                    .scaledToFit()
                    .ignoresSafeArea(edges: .bottom)
            }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    BackgroundView()
}
