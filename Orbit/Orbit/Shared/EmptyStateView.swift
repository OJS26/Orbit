

import SwiftUI

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image("NSULogo")
                .resizable()
                .scaledToFit()
                .frame(width: 120)
                .opacity(0.8)
            
            VStack(spacing: 8) {
                Text("No tasks yet")
                    .font(.title3.bold())
                    .foregroundStyle(.white)
                Text("Tap + to add your first habit and start your orbit.")
                    .font(.caption)
                    .foregroundStyle(Color("MutedLavender"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Spacer()
            
            Text("by North Star Unltd")
                .font(.caption2)
                .foregroundStyle(Color("MutedLavender").opacity(0.5))
                .padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    EmptyStateView()
        .background(Color("SpaceBackground"))
}
