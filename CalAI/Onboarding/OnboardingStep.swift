//
//  OnboardingStep.swift
//  CalAI
//
//  Created by Денис Николаев on 13.03.2025.
//

import Foundation

struct OnboardingStep: Identifiable {
    let id = UUID()
    let imageName: String
    let title: String
    let subtitle: String
}
