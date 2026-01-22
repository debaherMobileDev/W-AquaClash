//
//  OnboardingView.swift
//  W-AquaClash
//
//  Created by Simon Bakhanets on 22.01.2026.
//

import SwiftUI

struct OnboardingView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            Color.darkBlue.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Progress indicator
                HStack(spacing: 8) {
                    ForEach(0..<viewModel.pages.count, id: \.self) { index in
                        Circle()
                            .fill(index == viewModel.currentPage ? Color.brightBlue : Color.gray.opacity(0.5))
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.top, 40)
                .padding(.bottom, 20)
                
                // Page content
                TabView(selection: $viewModel.currentPage) {
                    ForEach(0..<viewModel.pages.count, id: \.self) { index in
                        OnboardingPageView(page: viewModel.pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                // Navigation buttons
                VStack(spacing: 16) {
                    if viewModel.isLastPage {
                        Button(action: {
                            completeOnboarding()
                        }) {
                            Text("Get Started")
                                .gameButtonStyle()
                        }
                        .padding(.horizontal, 30)
                    } else {
                        HStack {
                            Button(action: {
                                completeOnboarding()
                            }) {
                                Text("Skip")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                viewModel.nextPage()
                            }) {
                                HStack {
                                    Text("Next")
                                        .font(.system(size: 16, weight: .semibold))
                                    Image(systemName: "arrow.right")
                                }
                                .foregroundColor(.brightBlue)
                            }
                        }
                        .padding(.horizontal, 30)
                    }
                }
                .padding(.bottom, 40)
            }
        }
    }
    
    private func completeOnboarding() {
        hasCompletedOnboarding = true
        presentationMode.wrappedValue.dismiss()
    }
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Icon
            ZStack {
                Circle()
                    .fill(Color.brightBlue.opacity(0.2))
                    .frame(width: 120, height: 120)
                
                Image(systemName: page.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .foregroundColor(.brightBlue)
            }
            
            // Title
            Text(page.title)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            // Description
            Text(page.description)
                .font(.system(size: 17))
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .lineSpacing(6)
                .padding(.horizontal, 40)
            
            // Interactive demo based on step type
            if page.stepType == .currents {
                InteractiveDemoView()
                    .frame(height: 150)
                    .padding(.horizontal, 40)
            }
            
            Spacer()
        }
    }
}

struct InteractiveDemoView: View {
    @State private var dragStart: CGPoint?
    @State private var dragEnd: CGPoint?
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.duskyBlue)
            
            if let start = dragStart, let end = dragEnd {
                Path { path in
                    path.move(to: start)
                    path.addLine(to: end)
                }
                .stroke(Color.brightBlue, style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                
                Circle()
                    .fill(Color.brightBlue)
                    .frame(width: 10, height: 10)
                    .position(start)
                
                Image(systemName: "arrowtriangle.forward.fill")
                    .foregroundColor(.brightBlue)
                    .rotationEffect(Angle(radians: atan2(end.y - start.y, end.x - start.x)))
                    .position(end)
            } else {
                Text("Drag here to create a water current")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.5))
            }
        }
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    if dragStart == nil {
                        dragStart = value.startLocation
                    }
                    dragEnd = value.location
                }
                .onEnded { value in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        dragStart = nil
                        dragEnd = nil
                    }
                }
        )
    }
}

#Preview {
    OnboardingView()
}
