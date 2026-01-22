//
//  GameViewModel.swift
//  W-AquaClash
//
//  Created by Simon Bakhanets on 22.01.2026.
//

import Foundation
import SwiftUI
import Combine

class GameViewModel: ObservableObject {
    @Published var gameState: GameState = .notStarted
    @Published var currentLevel: GameLevel
    @Published var submarine: Submarine
    @Published var waterCurrents: [WaterCurrent] = []
    @Published var activePowerUps: [ActivePowerUp] = []
    @Published var score: Int = 0
    @Published var timeRemaining: Double
    @Published var powerUpsCollected: Int = 0
    @Published var obstaclesHit: Int = 0
    @Published var showLevelComplete: Bool = false
    @Published var showGameOver: Bool = false
    
    private var gameTimer: Timer?
    private var currentTouchStart: CGPoint?
    private let dataService: DataService
    private var screenSize: CGSize
    private var levelStartTime: Date?
    private var collectedPowerUpIds: Set<UUID> = []
    
    init(dataService: DataService, screenSize: CGSize = CGSize(width: 390, height: 844)) {
        self.dataService = dataService
        self.screenSize = screenSize
        
        // Initialize first level
        let level = GameEngineService.generateLevel(number: 1, screenSize: screenSize)
        self.currentLevel = level
        self.timeRemaining = level.timeLimit
        
        // Initialize submarine with user's selected skin
        self.submarine = Submarine(
            position: level.startPosition,
            skinType: dataService.userProfile.selectedSkin,
            accessory: dataService.userProfile.selectedAccessory
        )
    }
    
    // MARK: - Game Control
    func startGame() {
        resetGame()
        gameState = .playing
        levelStartTime = Date()
        dataService.recordGamePlayed()
        startGameLoop()
    }
    
    func pauseGame() {
        gameState = .paused
        stopGameLoop()
    }
    
    func resumeGame() {
        gameState = .playing
        startGameLoop()
    }
    
    func resetGame() {
        gameState = .notStarted
        submarine.position = currentLevel.startPosition
        submarine.velocity = CGVector.zero
        waterCurrents.removeAll()
        activePowerUps.removeAll()
        score = 0
        timeRemaining = currentLevel.timeLimit
        powerUpsCollected = 0
        obstaclesHit = 0
        collectedPowerUpIds.removeAll()
        showLevelComplete = false
        showGameOver = false
        
        // Reset power-ups
        for i in 0..<currentLevel.powerUps.count {
            currentLevel.powerUps[i].isCollected = false
        }
    }
    
    func loadLevel(_ levelNumber: Int) {
        currentLevel = GameEngineService.generateLevel(number: levelNumber, screenSize: screenSize)
        timeRemaining = currentLevel.timeLimit
        submarine = Submarine(
            position: currentLevel.startPosition,
            skinType: dataService.userProfile.selectedSkin,
            accessory: dataService.userProfile.selectedAccessory
        )
        resetGame()
    }
    
    func nextLevel() {
        let nextLevelNumber = currentLevel.levelNumber + 1
        loadLevel(nextLevelNumber)
        startGame()
    }
    
    func restartLevel() {
        loadLevel(currentLevel.levelNumber)
        startGame()
    }
    
    // MARK: - Game Loop
    private func startGameLoop() {
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0/60.0, repeats: true) { [weak self] _ in
            self?.updateGame(deltaTime: 1.0/60.0)
        }
    }
    
    private func stopGameLoop() {
        gameTimer?.invalidate()
        gameTimer = nil
    }
    
    private func updateGame(deltaTime: Double) {
        guard gameState == .playing else { return }
        
        // Update time
        timeRemaining -= deltaTime
        if timeRemaining <= 0 {
            timeRemaining = 0
            endGame(success: false)
            return
        }
        
        // Clean up expired water currents
        let currentTime = Date()
        waterCurrents.removeAll { current in
            current.isPlayerCreated && currentTime.timeIntervalSince(current.creationTime) > 3.0
        }
        
        // Clean up expired power-ups
        activePowerUps.removeAll { $0.isExpired }
        
        // Update submarine physics
        GameEngineService.updateSubmarinePosition(
            submarine: &submarine,
            waterCurrents: waterCurrents,
            activePowerUps: activePowerUps,
            deltaTime: deltaTime,
            screenBounds: CGRect(origin: .zero, size: screenSize)
        )
        
        // Check collisions with obstacles
        for obstacle in currentLevel.obstacles {
            if GameEngineService.checkCollision(submarine: submarine, obstacle: obstacle) {
                handleObstacleCollision()
            }
        }
        
        // Check power-up collection
        for i in 0..<currentLevel.powerUps.count {
            let powerUp = currentLevel.powerUps[i]
            if !collectedPowerUpIds.contains(powerUp.id) &&
               GameEngineService.checkPowerUpCollection(submarine: submarine, powerUp: powerUp) {
                collectPowerUp(powerUp)
                collectedPowerUpIds.insert(powerUp.id)
                currentLevel.powerUps[i].isCollected = true
            }
        }
        
        // Check if goal reached
        if GameEngineService.checkGoalReached(submarine: submarine, goalPosition: currentLevel.goalPosition) {
            endGame(success: true)
        }
    }
    
    // MARK: - Touch Handling
    func handleTouchBegan(at location: CGPoint) {
        guard gameState == .playing else { return }
        currentTouchStart = location
    }
    
    func handleTouchMoved(to location: CGPoint) {
        guard gameState == .playing else { return }
        // Visual feedback can be added here
    }
    
    func handleTouchEnded(at location: CGPoint) {
        guard gameState == .playing, let start = currentTouchStart else { return }
        
        // Create water current from drag gesture
        let current = GameEngineService.createWaterCurrent(from: start, to: location)
        waterCurrents.append(current)
        
        currentTouchStart = nil
    }
    
    // MARK: - Game Events
    private func handleObstacleCollision() {
        // Check if shield is active
        if activePowerUps.contains(where: { $0.type == .shield && !$0.isExpired }) {
            // Shield absorbs the hit
            activePowerUps.removeAll { $0.type == .shield }
            return
        }
        
        obstaclesHit += 1
        
        // Reduce submarine velocity
        submarine.velocity.dx *= 0.5
        submarine.velocity.dy *= 0.5
        
        // Provide haptic feedback if enabled
        if dataService.userProfile.settings.hapticFeedbackEnabled {
            #if os(iOS)
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            #endif
        }
    }
    
    private func collectPowerUp(_ powerUp: PowerUp) {
        powerUpsCollected += 1
        
        let powerUpDuration = 10.0
        let activePowerUp = ActivePowerUp(type: powerUp.type, duration: powerUpDuration)
        
        switch powerUp.type {
        case .speedBoost, .shield, .magneticCollector:
            activePowerUps.append(activePowerUp)
        case .timeExtension:
            timeRemaining += 15
        case .doublePoints:
            activePowerUps.append(activePowerUp)
        }
        
        // Provide haptic feedback
        if dataService.userProfile.settings.hapticFeedbackEnabled {
            #if os(iOS)
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            #endif
        }
    }
    
    private func endGame(success: Bool) {
        stopGameLoop()
        
        if success {
            gameState = .levelCompleted
            
            // Calculate score
            let finalScore = GameEngineService.calculateScore(
                timeRemaining: timeRemaining,
                powerUpsCollected: powerUpsCollected,
                obstaclesHit: obstaclesHit,
                difficulty: dataService.userProfile.settings.difficulty
            )
            score = finalScore
            
            // Calculate completion time
            let completionTime = currentLevel.timeLimit - timeRemaining
            
            // Record win
            dataService.recordGameWin(level: currentLevel.levelNumber, score: finalScore, time: completionTime)
            
            // Check achievements
            dataService.checkAndUnlockAchievements(
                levelCompleted: currentLevel.levelNumber,
                time: completionTime,
                powerUpsCollected: powerUpsCollected,
                totalPowerUps: currentLevel.powerUps.count,
                hitObstacles: obstaclesHit > 0
            )
            
            showLevelComplete = true
        } else {
            gameState = .gameOver
            showGameOver = true
        }
    }
    
    // MARK: - Utilities
    func updateScreenSize(_ size: CGSize) {
        self.screenSize = size
    }
}
