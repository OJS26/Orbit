

import SwiftUI

struct Star: Identifiable {
    let id = UUID()
    let x: Double
    let y: Double
    let size: Double
    let opacity: Double
}

struct StarfieldView: View {
    let stars: [Star] = (0..<80).map { _ in
        Star(
            x: Double.random(in: 0...1),
            y: Double.random(in: 0...1),
            size: Double.random(in: 1...3),
            opacity: Double.random(in: 0.1...0.8)
        )
    }
    
    @State private var twinkle = false
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(stars) { star in
                    Circle()
                        .fill(.white)
                        .frame(width: star.size, height: star.size)
                        .position(
                            x: star.x * geo.size.width,
                            y: star.y * geo.size.height
                        )
                        .opacity(twinkle ? star.opacity : star.opacity * 0.3)
                        .animation(
                            .easeInOut(duration: Double.random(in: 1.5...3.0))
                            .repeatForever(autoreverses: true)
                            .delay(Double.random(in: 0...2)),
                            value: twinkle
                        )
                }
            }
            .onAppear { twinkle = true }
        }
    }
}

#Preview {
    StarfieldView()
        .background(Color("SpaceBackground"))
        .ignoresSafeArea()
}
