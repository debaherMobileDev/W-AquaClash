//
//  UserProfileModel.swift
//  W-AquaClash
//
//  Created by Simon Bakhanets on 22.01.2026.
//

import Foundation

struct UserProfile: Codable {
    var username: String
    var totalScore: Int
    var highestLevel: Int
    var totalGamesPlayed: Int
    var totalWins: Int
    var currentCoins: Int
    var ownedSkins: Set<String>
    var ownedAccessories: Set<String>
    var selectedSkin: SubmarineSkin
    var selectedAccessory: SubmarineAccessory?
    var achievements: [Achievement]
    var settings: GameSettings
    var bestTimes: [Int: Double] // Level number to best time
    
    init() {
        self.username = "Captain"
        self.totalScore = 0
        self.highestLevel = 1
        self.totalGamesPlayed = 0
        self.totalWins = 0
        self.currentCoins = 0
        self.ownedSkins = [SubmarineSkin.classic.rawValue]
        self.ownedAccessories = []
        self.selectedSkin = .classic
        self.selectedAccessory = nil
        self.achievements = AchievementType.allCases.map { Achievement(type: $0) }
        self.settings = GameSettings()
        self.bestTimes = [:]
    }
    
    mutating func unlockAchievement(_ type: AchievementType) {
        if let index = achievements.firstIndex(where: { $0.type == type && !$0.isUnlocked }) {
            achievements[index].isUnlocked = true
            achievements[index].unlockedDate = Date()
            currentCoins += type.points
        }
    }
    
    mutating func updateBestTime(for level: Int, time: Double) {
        if let existingTime = bestTimes[level] {
            if time < existingTime {
                bestTimes[level] = time
            }
        } else {
            bestTimes[level] = time
        }
    }
    
    mutating func purchaseSkin(_ skin: SubmarineSkin) -> Bool {
        guard currentCoins >= skin.cost else { return false }
        guard !ownedSkins.contains(skin.rawValue) else { return false }
        
        currentCoins -= skin.cost
        ownedSkins.insert(skin.rawValue)
        return true
    }
    
    mutating func purchaseAccessory(_ accessory: SubmarineAccessory) -> Bool {
        guard currentCoins >= accessory.cost else { return false }
        guard !ownedAccessories.contains(accessory.rawValue) else { return false }
        
        currentCoins -= accessory.cost
        ownedAccessories.insert(accessory.rawValue)
        return true
    }
}

struct GameSettings: Codable {
    var soundEnabled: Bool
    var musicEnabled: Bool
    var hapticFeedbackEnabled: Bool
    var showTutorials: Bool
    var difficulty: GameDifficulty
    
    init() {
        self.soundEnabled = true
        self.musicEnabled = true
        self.hapticFeedbackEnabled = true
        self.showTutorials = true
        self.difficulty = .normal
    }
}

enum GameDifficulty: String, Codable, CaseIterable {
    case easy = "Easy"
    case normal = "Normal"
    case hard = "Hard"
    
    var currentMultiplier: Double {
        switch self {
        case .easy: return 0.8
        case .normal: return 1.0
        case .hard: return 1.5
        }
    }
    
    var scoreMultiplier: Double {
        switch self {
        case .easy: return 0.8
        case .normal: return 1.0
        case .hard: return 1.5
        }
    }
}

struct LeaderboardEntry: Identifiable, Codable {
    let id: UUID
    let username: String
    let score: Int
    let level: Int
    let date: Date
    
    init(id: UUID = UUID(), username: String, score: Int, level: Int, date: Date = Date()) {
        self.id = id
        self.username = username
        self.score = score
        self.level = level
        self.date = date
    }
}
