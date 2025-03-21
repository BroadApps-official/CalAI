//
//  Gender.swift
//  CalAI
//
//  Created by Денис Николаев on 13.03.2025.
//

import Foundation

enum Gender: String, CaseIterable, Codable {
    case women = "Women"
    case men = "Men"
}

enum Goal: String, CaseIterable, Codable {
    case loseWeight = "Lose weight"
    case maintainWeight = "Maintain weight"
    case gainWeight = "Gain weight"
}

struct UserData: Codable {
    var gender: Gender?
    var dateOfBirth: Date?
    var weight: Double?
    var height: Double?
    var goal: Goal?
    var targetWeight: Double?
}
