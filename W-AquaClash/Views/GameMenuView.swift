//
//  GameMenuView.swift
//  W-AquaClash
//
//  Created by Simon Bakhanets on 22.01.2026.
//

import SwiftUI

struct GameMenuView: View {
    @StateObject private var dataService = DataService()
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var showOnboarding = false
    @State private var showGame = false
    @State private var showSettings = false
    @State private var selectedLevel = 1
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.darkBlue.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    Spacer()
                    
                    // Logo area
                    VStack(spacing: 20) {
                        ZStack {
                            Circle()
                                .fill(Color.brightBlue.opacity(0.2))
                                .frame(width: 150, height: 150)
                            
                            Image(systemName: "water.waves")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80, height: 80)
                                .foregroundColor(.brightBlue)
                        }
                        
                        VStack(spacing: 8) {
                            Text("W-Aqua Clash")
                                .font(.system(size: 42, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text("Master the Currents")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.brightBlue)
                        }
                    }
                    .padding(.bottom, 60)
                    
                    // Menu buttons
                    VStack(spacing: 16) {
                        MenuButton(
                            icon: "play.fill",
                            title: "Play",
                            color: .brightBlue
                        ) {
                            selectedLevel = 1
                            showGame = true
                        }
                        
                        MenuButton(
                            icon: "list.number",
                            title: "Continue - Level \(dataService.userProfile.highestLevel)",
                            color: .green
                        ) {
                            selectedLevel = dataService.userProfile.highestLevel
                            showGame = true
                        }
                        
                        MenuButton(
                            icon: "gearshape.fill",
                            title: "Settings & Store",
                            color: .purple
                        ) {
                            showSettings = true
                        }
                        
                        MenuButton(
                            icon: "info.circle.fill",
                            title: "How to Play",
                            color: .orange
                        ) {
                            showOnboarding = true
                        }
                    }
                    .padding(.horizontal, 30)
                    
                    Spacer()
                    
                    // Stats footer
                    HStack(spacing: 30) {
                        StatBadge(
                            icon: "star.fill",
                            value: "\(dataService.userProfile.totalScore)",
                            color: .yellow
                        )
                        
                        StatBadge(
                            icon: "trophy.fill",
                            value: "\(dataService.userProfile.totalWins)",
                            color: .green
                        )
                        
                        StatBadge(
                            icon: "bitcoinsign.circle.fill",
                            value: "\(dataService.userProfile.currentCoins)",
                            color: .orange
                        )
                    }
                    .padding(.bottom, 40)
                }
            }
            .navigationBarHidden(true)
            .fullScreenCover(isPresented: $showGame) {
                GameView(dataService: dataService, level: selectedLevel)
            }
            .fullScreenCover(isPresented: $showSettings) {
                SettingsView(dataService: dataService)
            }
            .fullScreenCover(isPresented: $showOnboarding) {
                OnboardingView()
            }
            .onAppear {
                if !hasCompletedOnboarding {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        showOnboarding = true
                    }
                }
            }
        }
    }
}

struct MenuButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .frame(width: 30)
                
                Text(title)
                    .font(.system(size: 20, weight: .semibold))
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .bold))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 18)
            .background(color)
            .cornerRadius(16)
            .shadow(color: color.opacity(0.5), radius: 10, x: 0, y: 5)
        }
    }
}

struct StatBadge: View {
    let icon: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
        }
        .frame(width: 100)
        .padding(.vertical, 15)
        .background(Color.duskyBlue)
        .cornerRadius(12)
    }
}

#Preview {
    GameMenuView()
}
