
import SwiftUI

struct WeatherIconView: View {
    let iconURL: String
    
    var body: some View {
        AsyncImage(url: URL(string: iconURL)) { phase in
            switch phase {
            case .empty:
                ProgressView()
            case .success(let image):
                image
                    .resizable()
                    .scaledToFit()
            case .failure:
                Image(systemName: "cloud.sun.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(Color.appBlue)
            @unknown default:
                EmptyView()
            }
        }
    }
}
