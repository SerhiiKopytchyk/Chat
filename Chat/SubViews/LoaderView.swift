import SwiftUI
import Foundation

struct Loader: View {
    @State var degrees: CGFloat = 0
    @State var animate = false

    var body: some View {

        VStack {
            Circle()
                .trim(from: 0, to: 0.8)
                .stroke(
                    AngularGradient(gradient: .init(colors: [.orange, .red]), center: .center),
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .frame(width: 45, height: 45)
                .rotationEffect(.degrees(animate ? 360 : 0))
                .animation( .linear(duration: 0.7).repeatForever(autoreverses: false), value: animate)
                .padding()
                .onAppear {
                    DispatchQueue.main.async {
                        animate = true
                    }
            }
            Text("Please Wait...")

        }
        .padding()
        .background(Color.white.opacity(0.8))
        .cornerRadius(15)
    }
}
