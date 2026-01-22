//
//  SettingsViewModel.swift
//  W-AquaClash
//
//  Created by Simon Bakhanets on 22.01.2026.
//

import Foundation
import SwiftUI

class SettingsViewModel: ObservableObject {
    @Published var settings: GameSettings
    @Published var selectedTab: SettingsTab = .general
    
    private let dataService: DataService
    
    init(dataService: DataService) {
        self.dataService = dataService
        self.settings = dataService.userProfile.settings
    }
    
    enum SettingsTab: String, CaseIterable {
        case general = "General"
        case customization = "Customization"
        case achievements = "Achievements"
        case leaderboard = "Leaderboard"
    }
    
    // MARK: - Settings Management
    func toggleSound() {
        settings.soundEnabled.toggle()
        saveSettings()
    }
    
    func toggleMusic() {
        settings.musicEnabled.toggle()
        saveSettings()
    }
    
    func toggleHapticFeedback() {
        settings.hapticFeedbackEnabled.toggle()
        saveSettings()
    }
    
    func toggleTutorials() {
        settings.showTutorials.toggle()
        saveSettings()
    }
    
    func setDifficulty(_ difficulty: GameDifficulty) {
        settings.difficulty = difficulty
        saveSettings()
    }
    
    private func saveSettings() {
        dataService.updateSettings(settings)
    }
    
    // MARK: - Customization
    func purchaseSkin(_ skin: SubmarineSkin) -> Bool {
        return dataService.purchaseSkin(skin)
    }
    
    func purchaseAccessory(_ accessory: SubmarineAccessory) -> Bool {
        return dataService.purchaseAccessory(accessory)
    }
    
    func selectSkin(_ skin: SubmarineSkin) {
        dataService.selectSkin(skin)
    }
    
    func selectAccessory(_ accessory: SubmarineAccessory?) {
        dataService.selectAccessory(accessory)
    }
    
    func isSkinOwned(_ skin: SubmarineSkin) -> Bool {
        return dataService.userProfile.ownedSkins.contains(skin.rawValue)
    }
    
    func isAccessoryOwned(_ accessory: SubmarineAccessory) -> Bool {
        return dataService.userProfile.ownedAccessories.contains(accessory.rawValue)
    }
    
    func isSkinSelected(_ skin: SubmarineSkin) -> Bool {
        return dataService.userProfile.selectedSkin == skin
    }
    
    func isAccessorySelected(_ accessory: SubmarineAccessory) -> Bool {
        return dataService.userProfile.selectedAccessory == accessory
    }
    
    // MARK: - Profile Management
    func updateUsername(_ newName: String) {
        dataService.userProfile.username = newName
        dataService.saveUserProfile()
    }
    
    func resetProgress() {
        dataService.resetUserProfile()
        settings = dataService.userProfile.settings
    }
    
    // MARK: - Data Access
    var userProfile: UserProfile {
        return dataService.userProfile
    }
    
    var achievements: [Achievement] {
        return dataService.userProfile.achievements
    }
    
    var leaderboard: [LeaderboardEntry] {
        return dataService.leaderboard
    }
}
