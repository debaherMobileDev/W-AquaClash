//
//  DataService.swift
//  W-AquaClash
//
//  Created by Simon Bakhanets on 22.01.2026.
//

import Foundation

class DataService: ObservableObject {
    @Published var userProfile: UserProfile
    @Published var leaderboard: [LeaderboardEntry] = []
    
    private let userProfileKey = "userProfile"
    private let leaderboardKey = "leaderboard"
    
    init() {
        self.userProfile = DataService.loadUserProfile() ?? UserProfile()
        self.leaderboard = DataService.loadLeaderboard()
    }
    
    // MARK: - User Profile Management
    func saveUserProfile() {
        if let encoded = try? JSONEncoder().encode(userProfile) {
            UserDefaults.standard.set(encoded, forKey: userProfileKey)
        }
    }
    
    static func loadUserProfile() -> UserProfile? {
        guard let data = UserDefaults.standard.data(forKey: "userProfile"),
              let profile = try? JSONDecoder().decode(UserProfile.self, from: data) else {
            return nil
        }
        return profile
    }
    
    func resetUserProfile() {
        userProfile = UserProfile()
        saveUserProfile()
    }
    
    // MARK: - Leaderboard Management
    func addLeaderboardEntry(_ entry: LeaderboardEntry) {
        leaderboard.append(entry)
        leaderboard.sort { $0.score > $1.score }
        
        // Keep top 100 entries
        if leaderboard.count > 100 {
            leaderboard = Array(leaderboard.prefix(100))
        }
        
        saveLeaderboard()
    }
    
    func saveLeaderboard() {
        if let encoded = try? JSONEncoder().encode(leaderboard) {
            UserDefaults.standard.set(encoded, forKey: leaderboardKey)
        }
    }
    
    static func loadLeaderboard() -> [LeaderboardEntry] {
        guard let data = UserDefaults.standard.data(forKey: "leaderboard"),
              let entries = try? JSONDecoder().decode([LeaderboardEntry].self, from: data) else {
            return []
        }
        return entries
    }
    
    func clearLeaderboard() {
        leaderboard = []
        saveLeaderboard()
    }
    
    // MARK: - Achievement Management
    func unlockAchievement(_ type: AchievementType) {
        userProfile.unlockAchievement(type)
        saveUserProfile()
    }
    
    func checkAndUnlockAchievements(levelCompleted: Int, time: Double, powerUpsCollected: Int, totalPowerUps: Int, hitObstacles: Bool) {
        // First win
        if userProfile.totalWins == 1 {
            unlockAchievement(.firstWin)
        }
        
        // Ten wins
        if userProfile.totalWins == 10 {
            unlockAchievement(.tenWins)
        }
        
        // Speedster - complete level in under 20 seconds
        if time < 20 {
            unlockAchievement(.speedster)
        }
        
        // Collector - collect all power-ups
        if totalPowerUps > 0 && powerUpsCollected == totalPowerUps {
            unlockAchievement(.collector)
        }
        
        // Perfect run - no obstacles hit
        if !hitObstacles {
            unlockAchievement(.perfectRun)
        }
    }
    
    // MARK: - Store Management
    func purchaseSkin(_ skin: SubmarineSkin) -> Bool {
        let success = userProfile.purchaseSkin(skin)
        if success {
            saveUserProfile()
        }
        return success
    }
    
    func purchaseAccessory(_ accessory: SubmarineAccessory) -> Bool {
        let success = userProfile.purchaseAccessory(accessory)
        if success {
            saveUserProfile()
        }
        return success
    }
    
    func selectSkin(_ skin: SubmarineSkin) {
        guard userProfile.ownedSkins.contains(skin.rawValue) else { return }
        userProfile.selectedSkin = skin
        saveUserProfile()
    }
    
    func selectAccessory(_ accessory: SubmarineAccessory?) {
        if let accessory = accessory {
            guard userProfile.ownedAccessories.contains(accessory.rawValue) else { return }
        }
        userProfile.selectedAccessory = accessory
        saveUserProfile()
    }
    
    // MARK: - Game Stats
    func recordGameWin(level: Int, score: Int, time: Double) {
        userProfile.totalWins += 1
        userProfile.totalScore += score
        userProfile.currentCoins += score / 10 // Convert score to coins
        
        if level > userProfile.highestLevel {
            userProfile.highestLevel = level
        }
        
        userProfile.updateBestTime(for: level, time: time)
        
        // Add to leaderboard
        let entry = LeaderboardEntry(username: userProfile.username, score: score, level: level)
        addLeaderboardEntry(entry)
        
        saveUserProfile()
    }
    
    func recordGamePlayed() {
        userProfile.totalGamesPlayed += 1
        saveUserProfile()
    }
    
    // MARK: - Settings Management
    func updateSettings(_ settings: GameSettings) {
        userProfile.settings = settings
        saveUserProfile()
    }
}
