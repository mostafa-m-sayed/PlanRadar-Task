import SwiftUI

struct WeatherRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.3))
                .tracking(1)

            Spacer()

            Text(value)
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(Color.appBlue)
        }
    }
}
