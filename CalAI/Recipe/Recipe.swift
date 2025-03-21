//
//  Recipe.swift
//  CalAI
//
//  Created by Денис Николаев on 14.03.2025.
//

import Foundation

struct Recipe: Identifiable, Codable {
    let id = UUID()
    let name: String
    let category: String
    let calories: Int
    let protein: Int
    let carbs: Int
    let fats: Int
    let description: String
    let ingredients: [String]
    let imageName: String?
    
    enum CodingKeys: String, CodingKey {
        case id, name, category, calories, protein, carbs, fats, description, ingredients, imageName
    }
}

struct Category: Identifiable, Codable {
    let id = UUID()
    let name: String
    var count: Int
    
    enum CodingKeys: String, CodingKey {
        case id, name, count
    }
}

struct Ingredient: Codable, Identifiable {
    var id: UUID { UUID() }
    let ingredient: String
    let weight: Double

    enum CodingKeys: String, CodingKey {
        case ingredient
        case weight
    }
}
