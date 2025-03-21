//
//  OnboardingViewModel.swift
//  CalAI
//
//  Created by Денис Николаев on 13.03.2025.
//

import SwiftUI

class OnboardingViewModel: ObservableObject {
    @Published var steps: [OnboardingStep] = [
        OnboardingStep(imageName: "step1", title: "Monitor your nutrition \n with AI", subtitle: ""),
        OnboardingStep(imageName: "step2", title: "Turn everything you \n see", subtitle: ""),
        OnboardingStep(imageName: "step3", title: "Take a photo & \n enjoy", subtitle: ""),
        OnboardingStep(imageName: "step4", title: "Don't miss new \n trends", subtitle: "Allow notifications")
    ]
    
    @Published var currentPage = 0
    
    func nextPage() {
        if currentPage < steps.count - 1 {
            currentPage += 1
        } else {
            print("Onboarding Finished!")
        }
    }
}
