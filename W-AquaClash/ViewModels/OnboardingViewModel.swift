//
//  OnboardingViewModel.swift
//  W-AquaClash
//
//  Created by Simon Bakhanets on 22.01.2026.
//

import Foundation
import SwiftUI

class OnboardingViewModel: ObservableObject {
    @Published var currentPage: Int = 0
    @Published var username: String = ""
    
    let pages: [OnboardingPage] = [
        OnboardingPage(
            title: "Welcome to W-Aqua Clash",
            description: "Master the art of water current manipulation to guide your submarine through challenging underwater mazes!",
            imageName: "water.waves",
            stepType: .welcome
        ),
        OnboardingPage(
            title: "Create Water Currents",
            description: "Drag your finger across the screen to create powerful water currents that push your submarine in the desired direction.",
            imageName: "hand.draw",
            stepType: .currents
        ),
        OnboardingPage(
            title: "Navigate Obstacles",
            description: "Avoid rocks, mines, and other dangers as you navigate through increasingly complex levels.",
            imageName: "exclamationmark.triangle",
            stepType: .obstacles
        ),
        OnboardingPage(
            title: "Collect Power-Ups",
            description: "Gather special power-ups to gain speed boosts, shields, extra time, and more advantages!",
            imageName: "star.fill",
            stepType: .powerups
        ),
        OnboardingPage(
            title: "Reach the Goal",
            description: "Guide your submarine to the goal marker before time runs out to complete each level.",
            imageName: "flag.checkered",
            stepType: .goal
        ),
        OnboardingPage(
            title: "Customize Your Submarine",
            description: "Earn coins to unlock new submarine skins and accessories. Make your fleet truly unique!",
            imageName: "paintbrush.fill",
            stepType: .customization
        )
    ]
    
    var isLastPage: Bool {
        currentPage == pages.count - 1
    }
    
    func nextPage() {
        if currentPage < pages.count - 1 {
            withAnimation {
                currentPage += 1
            }
        }
    }
    
    func previousPage() {
        if currentPage > 0 {
            withAnimation {
                currentPage -= 1
            }
        }
    }
    
    func skipToEnd() {
        withAnimation {
            currentPage = pages.count - 1
        }
    }
}

struct OnboardingPage: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let imageName: String
    let stepType: OnboardingStepType
}

enum OnboardingStepType {
    case welcome
    case currents
    case obstacles
    case powerups
    case goal
    case customization
}
