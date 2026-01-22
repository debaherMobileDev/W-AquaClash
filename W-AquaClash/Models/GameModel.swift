//
//  GameModel.swift
//  W-AquaClash
//
//  Created by Simon Bakhanets on 22.01.2026.
//

import Foundation
import SwiftUI

// MARK: - Submarine Model
struct Submarine: Identifiable, Codable {
    let id: UUID
    var position: CGPoint
    var velocity: CGVector
    var skinType: SubmarineSkin
    var accessory: SubmarineAccessory?
    var isActive: Bool
    
    init(id: UUID = UUID(), position: CGPoint, skinType: SubmarineSkin = .classic, accessory: SubmarineAccessory? = nil) {
        self.id = id
        self.position = position
        self.velocity = CGVector(dx: 0, dy: 0)
        self.skinType = skinType
        self.accessory = accessory
        self.isActive = true
    }
}

// MARK: - Submarine Customization
enum SubmarineSkin: String, Codable, CaseIterable {
    case classic = "Classic"
    case stealth = "Stealth"
    case explorer = "Explorer"
    case military = "Military"
    case royal = "Royal"
    
    var cost: Int {
        switch self {
        case .classic: return 0
        case .stealth: return 500
        case .explorer: return 750
        case .military: return 1000
        case .royal: return 1500
        }
    }
    
    var color: Color {
        switch self {
        case .classic: return Color(hex: "01A2FF")
        case .stealth: return .gray
        case .explorer: return .orange
        case .military: return .green
        case .royal: return .purple
        }
    }
}

enum SubmarineAccessory: String, Codable, CaseIterable {
    case propeller = "Propeller"
    case sonar = "Sonar"
    case shield = "Shield"
    case speedBoost = "Speed Boost"
    
    var cost: Int {
        switch self {
        case .propeller: return 300
        case .sonar: return 400
        case .shield: return 500
        case .speedBoost: return 600
        }
    }
}

// MARK: - Water Current
struct WaterCurrent: Identifiable {
    let id: UUID
    var origin: CGPoint
    var direction: CGVector
    var strength: Double
    var radius: Double
    var isPlayerCreated: Bool
    var creationTime: Date
    
    init(id: UUID = UUID(), origin: CGPoint, direction: CGVector, strength: Double = 1.0, radius: Double = 100, isPlayerCreated: Bool = true) {
        self.id = id
        self.origin = origin
        self.direction = direction
        self.strength = strength
        self.radius = radius
        self.isPlayerCreated = isPlayerCreated
        self.creationTime = Date()
    }
}

// MARK: - Obstacles
enum ObstacleType: Codable {
    case rock
    case mine
    case coral
    case whirlpool
}

struct Obstacle: Identifiable, Codable {
    let id: UUID
    var position: CGPoint
    var size: CGSize
    var type: ObstacleType
    var rotation: Double
    
    init(id: UUID = UUID(), position: CGPoint, size: CGSize, type: ObstacleType, rotation: Double = 0) {
        self.id = id
        self.position = position
        self.size = size
        self.type = type
        self.rotation = rotation
    }
}

// MARK: - Power-ups
enum PowerUpType: String, Codable, CaseIterable {
    case speedBoost = "Speed Boost"
    case shield = "Shield"
    case timeExtension = "Time Extension"
    case magneticCollector = "Magnetic Collector"
    case doublePoints = "Double Points"
}

struct PowerUp: Identifiable, Codable {
    let id: UUID
    var position: CGPoint
    var type: PowerUpType
    var isCollected: Bool
    
    init(id: UUID = UUID(), position: CGPoint, type: PowerUpType) {
        self.id = id
        self.position = position
        self.type = type
        self.isCollected = false
    }
}

// MARK: - Level
struct GameLevel: Identifiable, Codable {
    let id: UUID
    var levelNumber: Int
    var obstacles: [Obstacle]
    var powerUps: [PowerUp]
    var startPosition: CGPoint
    var goalPosition: CGPoint
    var timeLimit: Double
    var targetScore: Int
    
    init(id: UUID = UUID(), levelNumber: Int, obstacles: [Obstacle] = [], powerUps: [PowerUp] = [], startPosition: CGPoint, goalPosition: CGPoint, timeLimit: Double = 60, targetScore: Int = 100) {
        self.id = id
        self.levelNumber = levelNumber
        self.obstacles = obstacles
        self.powerUps = powerUps
        self.startPosition = startPosition
        self.goalPosition = goalPosition
        self.timeLimit = timeLimit
        self.targetScore = targetScore
    }
}

// MARK: - Game State
enum GameState: Equatable {
    case notStarted
    case playing
    case paused
    case levelCompleted
    case gameOver
}

// MARK: - Active Power-up Tracking
struct ActivePowerUp: Identifiable {
    let id: UUID
    let type: PowerUpType
    let activationTime: Date
    let duration: Double
    
    var isExpired: Bool {
        Date().timeIntervalSince(activationTime) > duration
    }
    
    init(id: UUID = UUID(), type: PowerUpType, duration: Double = 10.0) {
        self.id = id
        self.type = type
        self.activationTime = Date()
        self.duration = duration
    }
}

// MARK: - Achievement
enum AchievementType: String, Codable, CaseIterable {
    case firstWin = "First Victory"
    case speedster = "Speedster"
    case collector = "Collector"
    case perfectRun = "Perfect Run"
    case tenWins = "Ten Victories"
    case masterNavigator = "Master Navigator"
    
    var description: String {
        switch self {
        case .firstWin: return "Complete your first level"
        case .speedster: return "Complete a level in under 20 seconds"
        case .collector: return "Collect all power-ups in a level"
        case .perfectRun: return "Complete a level without hitting obstacles"
        case .tenWins: return "Complete 10 levels"
        case .masterNavigator: return "Complete 5 levels in a row without losing"
        }
    }
    
    var points: Int {
        switch self {
        case .firstWin: return 100
        case .speedster: return 200
        case .collector: return 150
        case .perfectRun: return 250
        case .tenWins: return 500
        case .masterNavigator: return 750
        }
    }
}

struct Achievement: Identifiable, Codable {
    let id: UUID
    let type: AchievementType
    var isUnlocked: Bool
    var unlockedDate: Date?
    
    init(id: UUID = UUID(), type: AchievementType, isUnlocked: Bool = false) {
        self.id = id
        self.type = type
        self.isUnlocked = isUnlocked
        self.unlockedDate = nil
    }
}
