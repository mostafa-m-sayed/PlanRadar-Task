import SwiftUI

struct HeaderView: View {
    let onAddTap: () -> Void
    let addButtonOnLeft: Bool
    let imageName: String
    let header: String

    init(onAddTap: @escaping () -> Void, addButtonOnLeft: Bool = false, imageName: String = "plus", header: String = "CITIES") {
        self.onAddTap = onAddTap
        self.header = header
        self.addButtonOnLeft = addButtonOnLeft
        self.imageName = imageName
    }
    
    var body: some View {
        HStack {
            Spacer()
            Text(header)
                .font(.headline)
                .padding(.top, 20)
            Spacer()
        }
        .overlay(
            HStack {
                if addButtonOnLeft {
                    ActionButton(action: onAddTap, isOnLeft: true, imageName: imageName)
                        .padding(.leading, -20)
                    Spacer()
                } else {
                    Spacer()
                    ActionButton(action: onAddTap, isOnLeft: false, imageName: imageName)
                        .padding(.trailing, -20)
                }
            }
        )
        .padding(.bottom, 20)
    }
}

private struct ActionButton: View {
    let action: () -> Void
    let isOnLeft: Bool
    let imageName: String
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Color.appBlue
                Image(systemName: imageName)
                    .fontWeight(.light)
                    
                    .foregroundColor(.white)
                    .padding(isOnLeft ? .leading : .trailing, 20)
            }
        }
        .frame(width: 110, height: 60)
        .cornerRadius(20)
        .padding(.top, 20)
        .shadow(radius: 10)
    }
}

#Preview {
    HeaderView(onAddTap: {})
}
