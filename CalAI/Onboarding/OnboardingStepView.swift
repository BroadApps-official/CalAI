//
//  OnboardingStepView.swift
//  CalAI
//
//  Created by Денис Николаев on 13.03.2025.
//

import SwiftUI
import StoreKit
import UserNotifications

struct OnboardingStepView: View {
    let step: OnboardingStep
    let index: Int
    @ObservedObject var viewModel: OnboardingViewModel
    @State private var navigateToNextScreen = false
    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color(hex: "#131313")
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    Image(step.imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: geometry.size.width)
                        .clipped()
                        .offset(y: -geometry.safeAreaInsets.top)
                        .ignoresSafeArea(edges: .top)
                    
                    VStack(spacing: 6) {
                        Text(step.title)
                            .font(.system(size: 34, weight: .bold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        
                        Text(step.subtitle)
                            .font(.system(size: 17, weight: .regular, design: .default))
                            .foregroundColor(.gray)
                            .transition(.opacity)
                    }
                    .padding(.horizontal, 16)
                    Spacer()
                    
                    if index != 3 {
                        HStack {
                            ForEach(viewModel.steps.indices, id: \.self) { idx in
                                Circle()
                                    .frame(width: 8, height: 8)
                                    .foregroundColor(viewModel.currentPage == idx ? .white : .gray.opacity(0.5))
                            }
                        }
                        .padding(.bottom, 20)
                    }
                    
                    Button(action: {
                        if index == 3 {
                            requestNotificationPermission()
                            impactFeedback.impactOccurred()
                        } else {
                            viewModel.nextPage()
                            impactFeedback.impactOccurred()
                        }
                    }) {
                        Text(index == 3 ? "Turn on notifications" : "Continue")
                            .font(.system(size: 17))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(hex: "#0FB423"))
                            .cornerRadius(32)
                            .padding(.horizontal, 16)
                    }
                    
                    if index == 3 {
                        NavigationLink(destination: OnboardingChoose().navigationBarBackButtonHidden(true), isActive: $navigateToNextScreen) {
                            Text("Maybe Later")
                                .font(.system(size: 17, weight: .regular, design: .default))
                                .foregroundColor(.gray)
                                .transition(.opacity)
                        }
                        .padding(.top, 16) 
                    }
                    
                    NavigationLink(destination: OnboardingChoose().navigationBarBackButtonHidden(true), isActive: $navigateToNextScreen) {
                        EmptyView()
                    }
                    .hidden()
                }
                .padding(.bottom, max(geometry.safeAreaInsets.bottom, 10))
            }
        }
        .edgesIgnoringSafeArea(.top)
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Allow")
                navigateToNextScreen = true
                impactFeedback.impactOccurred()
            } else {
                navigateToNextScreen = true
            }
        }
    }
}

#Preview {
    OnboardingView()
}
