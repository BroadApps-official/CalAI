//
//  Entry.swift
//  CalAI
//
//  Created by Денис Николаев on 15.03.2025.
//

import Foundation

enum EntryType: String, CaseIterable {
    case meal = "Meal"
    case activity = "Activity"
}

enum NavigationDestination {
    case resultView
}

class EntryViewModel: ObservableObject {
    @Published var selectedType: EntryType = .meal
    @Published var description: String = ""
    
    func analyzeEntry() {
        print("Analyzing \(selectedType.rawValue): \(description)")
    }
}
