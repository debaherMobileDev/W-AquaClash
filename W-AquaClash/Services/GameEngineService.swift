//
//  GameEngineService.swift
//  W-AquaClash
//
//  Created by Simon Bakhanets on 22.01.2026.
//

import Foundation
import SwiftUI

class GameEngineService {
    
    // MARK: - Level Generation
    static func generateLevel(number: Int, screenSize: CGSize) -> GameLevel {
        let difficulty = min(number, 20) // Cap difficulty scaling at level 20
        
        let startPosition = CGPoint(x: 50, y: screenSize.height / 2)
        let goalPosition = CGPoint(x: screenSize.width - 50, y: screenSize.height / 2 + CGFloat.random(in: -100...100))
        
        var obstacles: [Obstacle] = []
        let obstacleCount = 3 + (difficulty / 2)
        
        for _ in 0..<obstacleCount {
            let obstacleType: ObstacleType = [.rock, .mine, .coral, .whirlpool].randomElement()!
            let size = CGSize(width: CGFloat.random(in: 30...60), height: CGFloat.random(in: 30...60))
            
            // Ensure obstacles are in the middle area, not blocking start/goal
            let x = CGFloat.random(in: 150...(screenSize.width - 150))
            let y = CGFloat.random(in: 100...(screenSize.height - 100))
            
            let obstacle = Obstacle(
                position: CGPoint(x: x, y: y),
                size: size,
                type: obstacleType,
                rotation: Double.random(in: 0...360)
            )
            obstacles.append(obstacle)
        }
        
        var powerUps: [PowerUp] = []
        let powerUpCount = 2 + (difficulty / 4)
        
        for _ in 0..<powerUpCount {
            let type = PowerUpType.allCases.randomElement()!
            let x = CGFloat.random(in: 100...(screenSize.width - 100))
            let y = CGFloat.random(in: 100...(screenSize.height - 100))
            
            let powerUp = PowerUp(position: CGPoint(x: x, y: y), type: type)
            powerUps.append(powerUp)
        }
        
        let timeLimit = max(30.0, 90.0 - Double(difficulty) * 2)
        let targetScore = 100 * difficulty
        
        return GameLevel(
            levelNumber: number,
            obstacles: obstacles,
            powerUps: powerUps,
            startPosition: startPosition,
            goalPosition: goalPosition,
            timeLimit: timeLimit,
            targetScore: targetScore
        )
    }
    
    // MARK: - Physics
    static func updateSubmarinePosition(
        submarine: inout Submarine,
        waterCurrents: [WaterCurrent],
        activePowerUps: [ActivePowerUp],
        deltaTime: Double,
        screenBounds: CGRect
    ) {
        // Apply water current forces
        var totalForce = CGVector.zero
        
        for current in waterCurrents {
            let distance = hypot(
                submarine.position.x - current.origin.x,
                submarine.position.y - current.origin.y
            )
            
            if distance < current.radius {
                let influence = 1.0 - (distance / current.radius)
                let force = CGVector(
                    dx: current.direction.dx * current.strength * influence,
                    dy: current.direction.dy * current.strength * influence
                )
                totalForce = CGVector(dx: totalForce.dx + force.dx, dy: totalForce.dy + force.dy)
            }
        }
        
        // Apply speed boost if active
        var speedMultiplier = 1.0
        if activePowerUps.contains(where: { $0.type == .speedBoost && !$0.isExpired }) {
            speedMultiplier = 1.5
        }
        
        // Update velocity
        submarine.velocity.dx += totalForce.dx * deltaTime * speedMultiplier
        submarine.velocity.dy += totalForce.dy * deltaTime * speedMultiplier
        
        // Apply drag/friction
        let drag = 0.95
        submarine.velocity.dx *= drag
        submarine.velocity.dy *= drag
        
        // Update position
        submarine.position.x += submarine.velocity.dx * deltaTime
        submarine.position.y += submarine.velocity.dy * deltaTime
        
        // Keep submarine within bounds
        submarine.position.x = max(20, min(screenBounds.width - 20, submarine.position.x))
        submarine.position.y = max(20, min(screenBounds.height - 20, submarine.position.y))
    }
    
    // MARK: - Collision Detection
    static func checkCollision(submarine: Submarine, obstacle: Obstacle) -> Bool {
        let submarineRadius: CGFloat = 20
        let obstacleRect = CGRect(
            x: obstacle.position.x - obstacle.size.width / 2,
            y: obstacle.position.y - obstacle.size.height / 2,
            width: obstacle.size.width,
            height: obstacle.size.height
        )
        
        // Check if submarine circle intersects with obstacle rectangle
        let closestX = max(obstacleRect.minX, min(submarine.position.x, obstacleRect.maxX))
        let closestY = max(obstacleRect.minY, min(submarine.position.y, obstacleRect.maxY))
        
        let distanceX = submarine.position.x - closestX
        let distanceY = submarine.position.y - closestY
        let distanceSquared = (distanceX * distanceX) + (distanceY * distanceY)
        
        return distanceSquared < (submarineRadius * submarineRadius)
    }
    
    static func checkPowerUpCollection(submarine: Submarine, powerUp: PowerUp) -> Bool {
        let distance = hypot(
            submarine.position.x - powerUp.position.x,
            submarine.position.y - powerUp.position.y
        )
        return distance < 30
    }
    
    static func checkGoalReached(submarine: Submarine, goalPosition: CGPoint) -> Bool {
        let distance = hypot(
            submarine.position.x - goalPosition.x,
            submarine.position.y - goalPosition.y
        )
        return distance < 40
    }
    
    // MARK: - Score Calculation
    static func calculateScore(
        timeRemaining: Double,
        powerUpsCollected: Int,
        obstaclesHit: Int,
        difficulty: GameDifficulty
    ) -> Int {
        let baseScore = 1000
        let timeBonus = Int(timeRemaining * 10)
        let powerUpBonus = powerUpsCollected * 50
        let obstaclePenalty = obstaclesHit * 100
        
        let totalScore = max(0, baseScore + timeBonus + powerUpBonus - obstaclePenalty)
        return Int(Double(totalScore) * difficulty.scoreMultiplier)
    }
    
    // MARK: - Water Current Helpers
    static func createWaterCurrent(from start: CGPoint, to end: CGPoint, strength: Double = 1.0) -> WaterCurrent {
        let dx = end.x - start.x
        let dy = end.y - start.y
        let magnitude = hypot(dx, dy)
        
        guard magnitude > 0 else {
            return WaterCurrent(origin: start, direction: CGVector.zero, strength: 0, radius: 0)
        }
        
        let normalizedDirection = CGVector(dx: dx / magnitude, dy: dy / magnitude)
        let currentStrength = min(magnitude / 10, 5.0) * strength
        
        return WaterCurrent(
            origin: start,
            direction: normalizedDirection,
            strength: currentStrength,
            radius: min(magnitude, 200)
        )
    }
}

// MARK: - CGVector Extension
extension CGVector {
    static var zero: CGVector {
        return CGVector(dx: 0, dy: 0)
    }
}
