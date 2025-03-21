//
//  Meal.swift
//  CalAI
//
//  Created by Денис Николаев on 13.03.2025.
//

import Foundation

struct Meal: Identifiable, Codable {
    let id = UUID()
    let name: String
    let calories: Int
    let protein: Int
    let carbs: Int
    let fats: Int
    let imageName: String?
    
    enum CodingKeys: String, CodingKey {
        case id, name, calories, protein, carbs, fats, imageName
    }
}

struct Activity: Identifiable, Codable {
    let id = UUID()
    let name: String
    let calories: Int
    let duration: String
    
    enum CodingKeys: String, CodingKey {
        case id, name, calories, duration
    }
}

struct DailyTracker: Codable {
    var date: Date
    var meals: [String: [Meal]]
    var activities: [Activity]
    var totalCalories: Int
    var totalProtein: Int
    var totalCarbs: Int
    var totalFats: Int
    
    enum CodingKeys: String, CodingKey {
        case date, meals, activities, totalCalories, totalProtein, totalCarbs, totalFats
    }
}
