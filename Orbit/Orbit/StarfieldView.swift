

import SwiftUI

struct Star: Identifiable {
    let id: Int
    let x: Double
    let y: Double
    let size: Double
    let opacity: Double
}

struct StarfieldView: View {
    let stars: [Star] = (0..<80).map { i in
        var gen = SeededRandomGenerator(seed: UInt64(i * 1234567))
        return Star(
            id: i,
            x: Double.random(in: 0...1, using: &gen),
            y: Double.random(in: 0...1, using: &gen),
            size: Double.random(in: 1...3, using: &gen),
            opacity: Double.random(in: 0.1...0.8, using: &gen)
        )
    }
    
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
                        .opacity(star.opacity)
                }
            }
        }
    }
}

struct SeededRandomGenerator: RandomNumberGenerator {
    var seed: UInt64
    
    mutating func next() -> UInt64 {
        seed = seed &* 6364136223846793005 &+ 1442695040888963407
        return seed
    }
}

#Preview {
    StarfieldView()
        .background(Color("SpaceBackground"))
        .ignoresSafeArea()
}
