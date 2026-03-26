

import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var currentPage = 0
    
    var body: some View {
        ZStack {
            Color("SpaceBackground")
                .ignoresSafeArea()
            
            StarfieldView()
                .ignoresSafeArea()
            
            VStack {
                TabView(selection: $currentPage) {
                    OnboardingPageView(
                        image: "NSULogo",
                        title: "Welcome to Orbit",
                        description: "A habit tracker built around your day. Add your routines, tap to complete them, and watch your orbit grow.",
                        showLogo: true
                    )
                    .tag(0)
                    
                    OnboardingPageView(
                        image: "checkmark.circle.fill",
                        title: "Build Your Routine",
                        description: "Add daily, weekly or monthly habits. Set how many times a day you want to complete them and when they reset.",
                        showLogo: false
                    )
                    .tag(1)
                    
                    OnboardingPageView(
                        image: "arrow.clockwise.circle.fill",
                        title: "Stay in Orbit",
                        description: "Your tasks reset automatically. Build streaks, track progress and keep your daily orbit on course.",
                        showLogo: false
                    )
                    .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(.page(backgroundDisplayMode: .always))
                
                Button {
                    if currentPage < 2 {
                        withAnimation {
                            currentPage += 1
                        }
                    } else {
                        hasSeenOnboarding = true
                    }
                } label: {
                    Text(currentPage < 2 ? "Next" : "Get Started")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color("AccentPurple"))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
                .animation(.easeInOut, value: currentPage)
            }
        }
    }
}

struct OnboardingPageView: View {
    let image: String
    let title: String
    let description: String
    let showLogo: Bool
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            if showLogo {
                Image(image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 140)
                    .opacity(0.9)
            } else {
                Image(systemName: image)
                    .font(.system(size: 80))
                    .foregroundStyle(LinearGradient(
                        colors: [Color("AccentPurple"), Color("NebulaBlue")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
            }
            
            VStack(spacing: 12) {
                Text(title)
                    .font(.title.bold())
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                
                Text(description)
                    .font(.body)
                    .foregroundStyle(Color("MutedLavender"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            Spacer()
            Spacer()
        }
    }
}

#Preview {
    OnboardingView()
}

