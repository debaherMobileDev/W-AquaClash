//
//  GameView.swift
//  W-AquaClash
//
//  Created by Simon Bakhanets on 22.01.2026.
//

import SwiftUI

struct GameView: View {
    @StateObject private var viewModel: GameViewModel
    @Environment(\.presentationMode) var presentationMode
    
    init(dataService: DataService, level: Int = 1) {
        let vm = GameViewModel(dataService: dataService)
        vm.loadLevel(level)
        _viewModel = StateObject(wrappedValue: vm)
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.darkBlue.ignoresSafeArea()
                
                // Game canvas
                GameCanvasView(viewModel: viewModel)
                    .onAppear {
                        viewModel.updateScreenSize(geometry.size)
                    }
                
                // HUD Overlay
                VStack {
                    GameHUDView(viewModel: viewModel) {
                        presentationMode.wrappedValue.dismiss()
                    }
                    
                    Spacer()
                }
                
                // Start overlay
                if viewModel.gameState == .notStarted {
                    StartOverlayView {
                        viewModel.startGame()
                    }
                }
                
                // Pause overlay
                if viewModel.gameState == .paused {
                    PauseOverlayView(
                        onResume: { viewModel.resumeGame() },
                        onRestart: { viewModel.restartLevel() },
                        onQuit: { presentationMode.wrappedValue.dismiss() }
                    )
                }
                
                // Level complete sheet
                if viewModel.showLevelComplete {
                    LevelCompleteView(
                        score: viewModel.score,
                        level: viewModel.currentLevel.levelNumber,
                        onNextLevel: { viewModel.nextLevel() },
                        onReplay: { viewModel.restartLevel() },
                        onQuit: { presentationMode.wrappedValue.dismiss() }
                    )
                }
                
                // Game over sheet
                if viewModel.showGameOver {
                    GameOverView(
                        level: viewModel.currentLevel.levelNumber,
                        onRetry: { viewModel.restartLevel() },
                        onQuit: { presentationMode.wrappedValue.dismiss() }
                    )
                }
            }
        }
        .navigationBarHidden(true)
    }
}

// MARK: - Game Canvas
struct GameCanvasView: View {
    @ObservedObject var viewModel: GameViewModel
    @State private var dragStart: CGPoint?
    @State private var dragCurrent: CGPoint?
    
    var body: some View {
        ZStack {
            // Goal
            Circle()
                .fill(Color.green.opacity(0.3))
                .frame(width: 80, height: 80)
                .position(viewModel.currentLevel.goalPosition)
                .overlay(
                    Image(systemName: "flag.checkered")
                        .font(.system(size: 30))
                        .foregroundColor(.green)
                        .position(viewModel.currentLevel.goalPosition)
                )
            
            // Obstacles
            ForEach(viewModel.currentLevel.obstacles) { obstacle in
                ObstacleView(obstacle: obstacle)
            }
            
            // Power-ups
            ForEach(viewModel.currentLevel.powerUps) { powerUp in
                if !powerUp.isCollected {
                    PowerUpView(powerUp: powerUp)
                }
            }
            
            // Water currents
            ForEach(viewModel.waterCurrents) { current in
                WaterCurrentView(current: current)
            }
            
            // Current drag gesture
            if let start = dragStart, let current = dragCurrent {
                Path { path in
                    path.move(to: start)
                    path.addLine(to: current)
                }
                .stroke(Color.brightBlue.opacity(0.5), style: StrokeStyle(lineWidth: 4, lineCap: .round, dash: [10, 5]))
                
                Circle()
                    .fill(Color.brightBlue.opacity(0.5))
                    .frame(width: 12, height: 12)
                    .position(start)
            }
            
            // Submarine
            SubmarineView(submarine: viewModel.submarine)
        }
        .gesture(
            DragGesture(minimumDistance: 10)
                .onChanged { value in
                    if dragStart == nil {
                        dragStart = value.startLocation
                        viewModel.handleTouchBegan(at: value.startLocation)
                    }
                    dragCurrent = value.location
                    viewModel.handleTouchMoved(to: value.location)
                }
                .onEnded { value in
                    viewModel.handleTouchEnded(at: value.location)
                    dragStart = nil
                    dragCurrent = nil
                }
        )
    }
}

// MARK: - Submarine View
struct SubmarineView: View {
    let submarine: Submarine
    
    var body: some View {
        ZStack {
            // Submarine body
            Capsule()
                .fill(submarine.skinType.color)
                .frame(width: 40, height: 20)
                .overlay(
                    Capsule()
                        .stroke(Color.white.opacity(0.5), lineWidth: 2)
                )
            
            // Window
            Circle()
                .fill(Color.white.opacity(0.6))
                .frame(width: 8, height: 8)
                .offset(x: 10)
        }
        .position(submarine.position)
        .rotationEffect(Angle(radians: atan2(submarine.velocity.dy, submarine.velocity.dx)))
    }
}

// MARK: - Obstacle View
struct ObstacleView: View {
    let obstacle: Obstacle
    
    var body: some View {
        Group {
            switch obstacle.type {
            case .rock:
                Image(systemName: "circle.hexagongrid.fill")
                    .foregroundColor(.gray)
            case .mine:
                Image(systemName: "circlebadge.fill")
                    .foregroundColor(.red)
            case .coral:
                Image(systemName: "leaf.fill")
                    .foregroundColor(.orange)
            case .whirlpool:
                Image(systemName: "hurricane")
                    .foregroundColor(.purple)
            }
        }
        .font(.system(size: obstacle.size.width))
        .position(obstacle.position)
        .rotationEffect(Angle(degrees: obstacle.rotation))
    }
}

// MARK: - Power-up View
struct PowerUpView: View {
    let powerUp: PowerUp
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            Circle()
                .fill(powerUpColor.opacity(0.3))
                .frame(width: 40, height: 40)
            
            Image(systemName: powerUpIcon)
                .font(.system(size: 20))
                .foregroundColor(powerUpColor)
        }
        .position(powerUp.position)
        .scaleEffect(isAnimating ? 1.1 : 0.9)
        .onAppear {
            withAnimation(Animation.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
    
    private var powerUpIcon: String {
        switch powerUp.type {
        case .speedBoost: return "hare.fill"
        case .shield: return "shield.fill"
        case .timeExtension: return "clock.fill"
        case .magneticCollector: return "magnifyingglass"
        case .doublePoints: return "star.fill"
        }
    }
    
    private var powerUpColor: Color {
        switch powerUp.type {
        case .speedBoost: return .yellow
        case .shield: return .blue
        case .timeExtension: return .cyan
        case .magneticCollector: return .purple
        case .doublePoints: return .orange
        }
    }
}

// MARK: - Water Current View
struct WaterCurrentView: View {
    let current: WaterCurrent
    @State private var animationOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.brightBlue.opacity(0.1))
                .frame(width: current.radius * 2, height: current.radius * 2)
                .position(current.origin)
            
            ForEach(0..<3, id: \.self) { index in
                Path { path in
                    let startPoint = current.origin
                    let endPoint = CGPoint(
                        x: startPoint.x + current.direction.dx * current.radius * 0.7,
                        y: startPoint.y + current.direction.dy * current.radius * 0.7
                    )
                    path.move(to: startPoint)
                    path.addLine(to: endPoint)
                }
                .stroke(Color.brightBlue.opacity(0.4 - Double(index) * 0.1),
                       style: StrokeStyle(lineWidth: 3, lineCap: .round, dash: [5, 5]))
                .offset(x: animationOffset * CGFloat(index + 1) * 5)
            }
        }
        .onAppear {
            withAnimation(Animation.linear(duration: 1.0).repeatForever(autoreverses: false)) {
                animationOffset = 10
            }
        }
    }
}

// MARK: - HUD
struct GameHUDView: View {
    @ObservedObject var viewModel: GameViewModel
    let onQuit: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "clock.fill")
                        .foregroundColor(.brightBlue)
                    Text(String(format: "%.0f", viewModel.timeRemaining))
                        .font(.system(size: 18, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                }
                
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text("\(viewModel.score)")
                        .font(.system(size: 18, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                }
                
                HStack {
                    Image(systemName: "flag.fill")
                        .foregroundColor(.green)
                    Text("Level \(viewModel.currentLevel.levelNumber)")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
            .padding()
            .background(Color.duskyBlue.opacity(0.8))
            .cornerRadius(12)
            
            Spacer()
            
            // Active power-ups
            if !viewModel.activePowerUps.isEmpty {
                VStack(spacing: 4) {
                    ForEach(viewModel.activePowerUps) { powerUp in
                        if !powerUp.isExpired {
                            HStack(spacing: 4) {
                                Image(systemName: powerUpIcon(for: powerUp.type))
                                    .font(.system(size: 14))
                                Text(String(format: "%.0f", powerUp.duration - Date().timeIntervalSince(powerUp.activationTime)))
                                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.brightBlue)
                            .cornerRadius(8)
                        }
                    }
                }
            }
            
            Spacer()
            
            VStack(spacing: 12) {
                Button(action: {
                    if viewModel.gameState == .playing {
                        viewModel.pauseGame()
                    }
                }) {
                    Image(systemName: "pause.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(Color.duskyBlue.opacity(0.8))
                        .cornerRadius(8)
                }
                
                Button(action: onQuit) {
                    Image(systemName: "xmark")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(Color.red.opacity(0.8))
                        .cornerRadius(8)
                }
            }
        }
        .padding()
    }
    
    private func powerUpIcon(for type: PowerUpType) -> String {
        switch type {
        case .speedBoost: return "hare.fill"
        case .shield: return "shield.fill"
        case .timeExtension: return "clock.fill"
        case .magneticCollector: return "magnifyingglass"
        case .doublePoints: return "star.fill"
        }
    }
}

// MARK: - Overlays
struct StartOverlayView: View {
    let onStart: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.7).ignoresSafeArea()
            
            VStack(spacing: 30) {
                Text("Ready to Navigate?")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Create water currents by dragging your finger to guide the submarine to the goal!")
                    .font(.system(size: 18))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                Button(action: onStart) {
                    Text("Start")
                        .gameButtonStyle()
                        .padding(.horizontal, 60)
                }
            }
        }
    }
}

struct PauseOverlayView: View {
    let onResume: () -> Void
    let onRestart: () -> Void
    let onQuit: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.7).ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("Paused")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.bottom, 20)
                
                Button(action: onResume) {
                    Text("Resume")
                        .gameButtonStyle()
                }
                
                Button(action: onRestart) {
                    Text("Restart Level")
                        .gameButtonStyle()
                }
                
                Button(action: onQuit) {
                    Text("Quit to Menu")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.duskyBlue)
                        .cornerRadius(12)
                }
            }
            .padding(.horizontal, 40)
        }
    }
}

struct LevelCompleteView: View {
    let score: Int
    let level: Int
    let onNextLevel: () -> Void
    let onReplay: () -> Void
    let onQuit: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.7).ignoresSafeArea()
            
            VStack(spacing: 25) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.green)
                
                Text("Level Complete!")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
                
                VStack(spacing: 12) {
                    HStack {
                        Text("Level:")
                            .foregroundColor(.white.opacity(0.7))
                        Spacer()
                        Text("\(level)")
                            .font(.system(size: 24, weight: .bold, design: .monospaced))
                            .foregroundColor(.brightBlue)
                    }
                    
                    HStack {
                        Text("Score:")
                            .foregroundColor(.white.opacity(0.7))
                        Spacer()
                        Text("\(score)")
                            .font(.system(size: 24, weight: .bold, design: .monospaced))
                            .foregroundColor(.yellow)
                    }
                }
                .padding()
                .background(Color.duskyBlue)
                .cornerRadius(12)
                
                VStack(spacing: 15) {
                    Button(action: onNextLevel) {
                        Text("Next Level")
                            .gameButtonStyle()
                    }
                    
                    Button(action: onReplay) {
                        Text("Replay Level")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.duskyBlue)
                            .cornerRadius(12)
                    }
                    
                    Button(action: onQuit) {
                        Text("Main Menu")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(.horizontal, 40)
        }
    }
}

struct GameOverView: View {
    let level: Int
    let onRetry: () -> Void
    let onQuit: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.7).ignoresSafeArea()
            
            VStack(spacing: 25) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.red)
                
                Text("Time's Up!")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Level \(level)")
                    .font(.system(size: 24))
                    .foregroundColor(.white.opacity(0.7))
                
                VStack(spacing: 15) {
                    Button(action: onRetry) {
                        Text("Try Again")
                            .gameButtonStyle()
                    }
                    
                    Button(action: onQuit) {
                        Text("Main Menu")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.duskyBlue)
                            .cornerRadius(12)
                    }
                }
            }
            .padding(.horizontal, 40)
        }
    }
}

#Preview {
    GameView(dataService: DataService(), level: 1)
}
