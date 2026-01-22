//
//  SettingsView.swift
//  W-AquaClash
//
//  Created by Simon Bakhanets on 22.01.2026.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel: SettingsViewModel
    @Environment(\.presentationMode) var presentationMode
    
    init(dataService: DataService) {
        _viewModel = StateObject(wrappedValue: SettingsViewModel(dataService: dataService))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.darkBlue.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Tab selector
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(SettingsViewModel.SettingsTab.allCases, id: \.self) { tab in
                                TabButton(
                                    title: tab.rawValue,
                                    isSelected: viewModel.selectedTab == tab,
                                    action: { viewModel.selectedTab = tab }
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical, 12)
                    
                    // Content
                    ScrollView {
                        VStack(spacing: 20) {
                            switch viewModel.selectedTab {
                            case .general:
                                GeneralSettingsView(viewModel: viewModel)
                            case .customization:
                                CustomizationView(viewModel: viewModel)
                            case .achievements:
                                AchievementsView(viewModel: viewModel)
                            case .leaderboard:
                                LeaderboardView(viewModel: viewModel)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.brightBlue)
                    }
                }
            }
        }
    }
}

// MARK: - Tab Button
struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: isSelected ? .bold : .medium))
                .foregroundColor(isSelected ? .white : .white.opacity(0.6))
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(isSelected ? Color.brightBlue : Color.duskyBlue)
                .cornerRadius(20)
        }
    }
}

// MARK: - General Settings
struct GeneralSettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel
    @State private var showResetAlert = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Profile section
            VStack(alignment: .leading, spacing: 12) {
                Text("Profile")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                
                VStack(spacing: 15) {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.brightBlue)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(viewModel.userProfile.username)
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text("Level \(viewModel.userProfile.highestLevel)")
                                .font(.system(size: 16))
                                .foregroundColor(.white.opacity(0.7))
                        }
                        
                        Spacer()
                    }
                    
                    Divider().background(Color.white.opacity(0.2))
                    
                    StatRow(icon: "star.fill", label: "Total Score", value: "\(viewModel.userProfile.totalScore)", color: .yellow)
                    StatRow(icon: "gamecontroller.fill", label: "Games Played", value: "\(viewModel.userProfile.totalGamesPlayed)", color: .blue)
                    StatRow(icon: "trophy.fill", label: "Wins", value: "\(viewModel.userProfile.totalWins)", color: .green)
                    StatRow(icon: "bitcoinsign.circle.fill", label: "Coins", value: "\(viewModel.userProfile.currentCoins)", color: .orange)
                }
                .cardStyle()
            }
            
            // Audio settings
            VStack(alignment: .leading, spacing: 12) {
                Text("Audio")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                
                VStack(spacing: 15) {
                    ToggleRow(icon: "speaker.wave.2.fill", label: "Sound Effects", isOn: $viewModel.settings.soundEnabled) {
                        viewModel.toggleSound()
                    }
                    
                    ToggleRow(icon: "music.note", label: "Music", isOn: $viewModel.settings.musicEnabled) {
                        viewModel.toggleMusic()
                    }
                }
                .cardStyle()
            }
            
            // Gameplay settings
            VStack(alignment: .leading, spacing: 12) {
                Text("Gameplay")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                
                VStack(spacing: 15) {
                    ToggleRow(icon: "hand.tap.fill", label: "Haptic Feedback", isOn: $viewModel.settings.hapticFeedbackEnabled) {
                        viewModel.toggleHapticFeedback()
                    }
                    
                    ToggleRow(icon: "questionmark.circle.fill", label: "Show Tutorials", isOn: $viewModel.settings.showTutorials) {
                        viewModel.toggleTutorials()
                    }
                    
                    Divider().background(Color.white.opacity(0.2))
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Difficulty")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                        
                        HStack(spacing: 12) {
                            ForEach(GameDifficulty.allCases, id: \.self) { difficulty in
                                Button(action: {
                                    viewModel.setDifficulty(difficulty)
                                }) {
                                    Text(difficulty.rawValue)
                                        .font(.system(size: 14, weight: viewModel.settings.difficulty == difficulty ? .bold : .medium))
                                        .foregroundColor(viewModel.settings.difficulty == difficulty ? .white : .white.opacity(0.6))
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(viewModel.settings.difficulty == difficulty ? Color.brightBlue : Color.darkBlue)
                                        .cornerRadius(8)
                                }
                            }
                        }
                    }
                }
                .cardStyle()
            }
            
            // Danger zone
            VStack(alignment: .leading, spacing: 12) {
                Text("Danger Zone")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.red)
                
                Button(action: {
                    showResetAlert = true
                }) {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                        Text("Reset All Progress")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.red)
                    .cornerRadius(12)
                }
            }
        }
        .alert(isPresented: $showResetAlert) {
            Alert(
                title: Text("Reset Progress"),
                message: Text("Are you sure you want to reset all progress? This action cannot be undone."),
                primaryButton: .destructive(Text("Reset")) {
                    viewModel.resetProgress()
                },
                secondaryButton: .cancel()
            )
        }
    }
}

struct StatRow: View {
    let icon: String
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24)
            Text(label)
                .foregroundColor(.white.opacity(0.8))
            Spacer()
            Text(value)
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
        }
    }
}

struct ToggleRow: View {
    let icon: String
    let label: String
    @Binding var isOn: Bool
    let action: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.brightBlue)
                .frame(width: 24)
            Text(label)
                .foregroundColor(.white)
            Spacer()
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .onChange(of: isOn) { _ in
                    action()
                }
        }
    }
}

// MARK: - Customization View
struct CustomizationView: View {
    @ObservedObject var viewModel: SettingsViewModel
    @State private var showPurchaseAlert = false
    @State private var purchaseMessage = ""
    
    var body: some View {
        VStack(spacing: 20) {
            // Coins display
            HStack {
                Image(systemName: "bitcoinsign.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.orange)
                Text("\(viewModel.userProfile.currentCoins) Coins")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
            }
            .cardStyle()
            
            // Submarine skins
            VStack(alignment: .leading, spacing: 12) {
                Text("Submarine Skins")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                    ForEach(SubmarineSkin.allCases, id: \.self) { skin in
                        SkinCard(
                            skin: skin,
                            isOwned: viewModel.isSkinOwned(skin),
                            isSelected: viewModel.isSkinSelected(skin),
                            coins: viewModel.userProfile.currentCoins,
                            onSelect: { viewModel.selectSkin(skin) },
                            onPurchase: {
                                if viewModel.purchaseSkin(skin) {
                                    purchaseMessage = "Successfully purchased \(skin.rawValue)!"
                                } else {
                                    purchaseMessage = "Not enough coins!"
                                }
                                showPurchaseAlert = true
                            }
                        )
                    }
                }
            }
            
            // Accessories
            VStack(alignment: .leading, spacing: 12) {
                Text("Accessories")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                    ForEach(SubmarineAccessory.allCases, id: \.self) { accessory in
                        AccessoryCard(
                            accessory: accessory,
                            isOwned: viewModel.isAccessoryOwned(accessory),
                            isSelected: viewModel.isAccessorySelected(accessory),
                            coins: viewModel.userProfile.currentCoins,
                            onSelect: { viewModel.selectAccessory(accessory) },
                            onPurchase: {
                                if viewModel.purchaseAccessory(accessory) {
                                    purchaseMessage = "Successfully purchased \(accessory.rawValue)!"
                                } else {
                                    purchaseMessage = "Not enough coins!"
                                }
                                showPurchaseAlert = true
                            }
                        )
                    }
                }
            }
        }
        .alert(isPresented: $showPurchaseAlert) {
            Alert(title: Text("Store"), message: Text(purchaseMessage), dismissButton: .default(Text("OK")))
        }
    }
}

struct SkinCard: View {
    let skin: SubmarineSkin
    let isOwned: Bool
    let isSelected: Bool
    let coins: Int
    let onSelect: () -> Void
    let onPurchase: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(skin.color.opacity(0.3))
                    .frame(width: 80, height: 80)
                
                // Submarine preview
                Capsule()
                    .fill(skin.color)
                    .frame(width: 50, height: 25)
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.green)
                        .offset(x: 35, y: -35)
                }
            }
            
            Text(skin.rawValue)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
            
            if isOwned {
                if !isSelected {
                    Button(action: onSelect) {
                        Text("Select")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(Color.brightBlue)
                            .cornerRadius(8)
                    }
                } else {
                    Text("Equipped")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.green)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
            } else {
                Button(action: onPurchase) {
                    HStack(spacing: 4) {
                        Image(systemName: "bitcoinsign.circle.fill")
                            .font(.system(size: 12))
                        Text("\(skin.cost)")
                            .font(.system(size: 14, weight: .medium))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(coins >= skin.cost ? Color.orange : Color.gray)
                    .cornerRadius(8)
                }
                .disabled(coins < skin.cost)
            }
        }
        .padding()
        .background(Color.duskyBlue)
        .cornerRadius(12)
    }
}

struct AccessoryCard: View {
    let accessory: SubmarineAccessory
    let isOwned: Bool
    let isSelected: Bool
    let coins: Int
    let onSelect: () -> Void
    let onPurchase: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.purple.opacity(0.3))
                    .frame(width: 80, height: 80)
                
                Image(systemName: accessoryIcon)
                    .font(.system(size: 40))
                    .foregroundColor(.purple)
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.green)
                        .offset(x: 35, y: -35)
                }
            }
            
            Text(accessory.rawValue)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            
            if isOwned {
                if !isSelected {
                    Button(action: onSelect) {
                        Text("Select")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(Color.brightBlue)
                            .cornerRadius(8)
                    }
                } else {
                    Text("Equipped")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.green)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
            } else {
                Button(action: onPurchase) {
                    HStack(spacing: 4) {
                        Image(systemName: "bitcoinsign.circle.fill")
                            .font(.system(size: 12))
                        Text("\(accessory.cost)")
                            .font(.system(size: 14, weight: .medium))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(coins >= accessory.cost ? Color.orange : Color.gray)
                    .cornerRadius(8)
                }
                .disabled(coins < accessory.cost)
            }
        }
        .padding()
        .background(Color.duskyBlue)
        .cornerRadius(12)
    }
    
    private var accessoryIcon: String {
        switch accessory {
        case .propeller: return "fan.fill"
        case .sonar: return "waveform"
        case .shield: return "shield.fill"
        case .speedBoost: return "bolt.fill"
        }
    }
}

// MARK: - Achievements View
struct AchievementsView: View {
    @ObservedObject var viewModel: SettingsViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            let unlockedCount = viewModel.achievements.filter { $0.isUnlocked }.count
            let totalCount = viewModel.achievements.count
            
            // Progress summary
            VStack(spacing: 12) {
                Text("\(unlockedCount) / \(totalCount)")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Achievements Unlocked")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.7))
                
                ProgressView(value: Double(unlockedCount), total: Double(totalCount))
                    .tint(.brightBlue)
            }
            .cardStyle()
            
            // Achievement list
            VStack(spacing: 12) {
                ForEach(viewModel.achievements) { achievement in
                    AchievementCard(achievement: achievement)
                }
            }
        }
    }
}

struct AchievementCard: View {
    let achievement: Achievement
    
    var body: some View {
        HStack(spacing: 15) {
            ZStack {
                Circle()
                    .fill(achievement.isUnlocked ? Color.brightBlue.opacity(0.3) : Color.gray.opacity(0.2))
                    .frame(width: 60, height: 60)
                
                Image(systemName: achievement.isUnlocked ? "star.fill" : "lock.fill")
                    .font(.system(size: 28))
                    .foregroundColor(achievement.isUnlocked ? .yellow : .gray)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(achievement.type.rawValue)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                
                Text(achievement.type.description)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.7))
                    .lineLimit(2)
                
                if achievement.isUnlocked, let date = achievement.unlockedDate {
                    Text(date, style: .date)
                        .font(.system(size: 12))
                        .foregroundColor(.brightBlue)
                }
            }
            
            Spacer()
            
            VStack {
                Image(systemName: "bitcoinsign.circle.fill")
                    .foregroundColor(.orange)
                Text("\(achievement.type.points)")
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
            }
        }
        .padding()
        .background(Color.duskyBlue)
        .cornerRadius(12)
        .opacity(achievement.isUnlocked ? 1.0 : 0.6)
    }
}

// MARK: - Leaderboard View
struct LeaderboardView: View {
    @ObservedObject var viewModel: SettingsViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            if viewModel.leaderboard.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    
                    Text("No Scores Yet")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Complete levels to see your scores appear here!")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                }
                .cardStyle()
            } else {
                ForEach(Array(viewModel.leaderboard.enumerated()), id: \.element.id) { index, entry in
                    LeaderboardEntryCard(entry: entry, rank: index + 1)
                }
            }
        }
    }
}

struct LeaderboardEntryCard: View {
    let entry: LeaderboardEntry
    let rank: Int
    
    var body: some View {
        HStack(spacing: 15) {
            // Rank
            ZStack {
                Circle()
                    .fill(rankColor.opacity(0.3))
                    .frame(width: 50, height: 50)
                
                Text("\(rank)")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(rankColor)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.username)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                
                HStack(spacing: 8) {
                    HStack(spacing: 4) {
                        Image(systemName: "flag.fill")
                            .font(.system(size: 12))
                        Text("Level \(entry.level)")
                            .font(.system(size: 14))
                    }
                    .foregroundColor(.brightBlue)
                    
                    Text(entry.date, style: .date)
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.5))
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(entry.score)")
                    .font(.system(size: 24, weight: .bold, design: .monospaced))
                    .foregroundColor(.yellow)
                
                Text("points")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.5))
            }
        }
        .padding()
        .background(Color.duskyBlue)
        .cornerRadius(12)
    }
    
    private var rankColor: Color {
        switch rank {
        case 1: return .yellow
        case 2: return .gray
        case 3: return Color(red: 0.8, green: 0.5, blue: 0.2)
        default: return .brightBlue
        }
    }
}

#Preview {
    SettingsView(dataService: DataService())
}
