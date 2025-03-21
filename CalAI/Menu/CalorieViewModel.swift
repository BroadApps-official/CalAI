//
//  CalorieViewModel.swift
//  CalAI
//
//  Created by Денис Николаев on 13.03.2025.
//

import SwiftUI

class CalorieViewModel: ObservableObject {
    @Published var dailyTrackers: [Date: DailyTracker] {
        didSet {
            saveDailyTrackers()
        }
    }
    
    @Published var selectedDate: Date = Date() {
        didSet {
            let normalizedDate = Calendar.current.startOfDay(for: selectedDate)
            if dailyTrackers[normalizedDate] == nil {
                dailyTrackers[normalizedDate] = DailyTracker(
                    date: selectedDate,
                    meals: ["Breakfast": [], "Lunch": [], "Dinner": [], "Snack": [], "Other": []],
                    activities: [],
                    totalCalories: 0,
                    totalProtein: 0,
                    totalCarbs: 0,
                    totalFats: 0
                )
            }
        }
    }
    
    @Published var userData: UserData {
        didSet {
            print("DEBUG: userData didSet triggered with: \(String(describing: userData))")
            updateGoals()
        }
    }
    
    @Published private(set) var calorieGoal: Int = 2000
    @Published private(set) var proteinGoal: Int = 150
    @Published private(set) var carbsGoal: Int = 200
    @Published private(set) var fatsGoal: Int = 80
    
    init() {
        self.userData = CalorieViewModel.loadUserData() ?? UserData()
        self.dailyTrackers = CalorieViewModel.loadDailyTrackers()
        print("DEBUG: Initializing with userData: \(String(describing: userData))")
        updateGoals()
        
        // Observe UserData updates
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("UserDataUpdated"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            print("DEBUG: Received UserDataUpdated notification")
            self?.syncUserData()
        }
    }
    
    // Check if there is a record (meals or activities) for a given date
    func hasRecord(for date: Date) -> Bool {
        let normalizedDate = normalizeDate(date)
        guard let tracker = dailyTrackers[normalizedDate] else { return false }
        
        // Check if there are any meals in any category
        let hasMeals = tracker.meals.values.contains { !$0.isEmpty }
        // Check if there are any activities
        let hasActivities = !tracker.activities.isEmpty
        
        return hasMeals || hasActivities
    }
    
    private func normalizeDate(_ date: Date) -> Date {
        Calendar.current.startOfDay(for: date)
    }
    
    private var currentTracker: DailyTracker? {
        dailyTrackers[normalizeDate(selectedDate)]
    }
    
    private func updateGoals() {
        print("DEBUG: updateGoals() called")
        guard let gender = userData.gender,
              let weight = userData.weight,
              let height = userData.height,
              let dateOfBirth = userData.dateOfBirth,
              let goal = userData.goal else {
            print("DEBUG: Missing user data, using defaults")
            calorieGoal = 2000
            proteinGoal = 0
            carbsGoal = 0
            fatsGoal = 0
            return
        }
        
        let age = Calendar.current.dateComponents([.year], from: dateOfBirth, to: Date()).year ?? 0
        
        let bmr: Double
        switch gender {
        case .men:
            bmr = 10 * weight + 6.25 * height - 5 * Double(age) + 5
        case .women:
            bmr = 10 * weight + 6.25 * height - 5 * Double(age) - 161
        }
        let tdee = bmr * 1.55
        
        switch goal {
        case .loseWeight:
            calorieGoal = Int(tdee - 500)
        case .maintainWeight:
            calorieGoal = Int(tdee)
        case .gainWeight:
            calorieGoal = Int(tdee + 500)
        }
        
        proteinGoal = Int(weight * 2)
        let fatCalories = Double(calorieGoal) * 0.25
        fatsGoal = Int(fatCalories / 9)
        let proteinCalories = Double(proteinGoal) * 4
        let carbsCalories = Double(calorieGoal) - proteinCalories - fatCalories
        carbsGoal = Int(carbsCalories / 4)
        
    }
    
    func caloriesLeft() -> Int {
        guard let tracker = currentTracker else { return calorieGoal }
        return calorieGoal - tracker.totalCalories
    }
    
    func totalCaloriesConsumed() -> Int {
        let consumed = currentTracker?.totalCalories ?? 0
        return max(0, consumed) // Ensure non-negative value for UI
    }
    
    func meals(for category: String) -> [Meal] {
        currentTracker?.meals[category] ?? []
    }
    
    func activities() -> [Activity] {
        currentTracker?.activities ?? []
    }
    
    func addMeal(_ meal: Meal, to category: String) {
        let normalizedDate = normalizeDate(selectedDate)
        var tracker = dailyTrackers[normalizedDate] ?? DailyTracker(
            date: selectedDate,
            meals: ["Breakfast": [], "Lunch": [], "Dinner": [], "Snack": [], "Other": []],
            activities: [],
            totalCalories: 0,
            totalProtein: 0,
            totalCarbs: 0,
            totalFats: 0
        )
        tracker.meals[category, default: []].append(meal)
        tracker.totalCalories += meal.calories
        tracker.totalProtein += meal.protein
        tracker.totalCarbs += meal.carbs
        tracker.totalFats += meal.fats
        dailyTrackers[normalizedDate] = tracker
    }
    
    func removeMeal(_ meal: Meal, from category: String) {
        let normalizedDate = normalizeDate(selectedDate)
        guard var tracker = dailyTrackers[normalizedDate] else { return }
        if var categoryMeals = tracker.meals[category],
           let index = categoryMeals.firstIndex(where: { $0.id == meal.id }) {
            let removedMeal = categoryMeals.remove(at: index)
            tracker.meals[category] = categoryMeals
            tracker.totalCalories -= removedMeal.calories
            tracker.totalProtein -= removedMeal.protein
            tracker.totalCarbs -= removedMeal.carbs
            tracker.totalFats -= removedMeal.fats
            dailyTrackers[normalizedDate] = tracker
        }
    }
    
    func addActivity(_ activity: Activity) {
        let normalizedDate = normalizeDate(selectedDate)
        var tracker = dailyTrackers[normalizedDate] ?? DailyTracker(
            date: selectedDate,
            meals: ["Breakfast": [], "Lunch": [], "Dinner": [], "Snack": [], "Other": []],
            activities: [],
            totalCalories: 0,
            totalProtein: 0,
            totalCarbs: 0,
            totalFats: 0
        )
        tracker.activities.append(activity)
        tracker.totalCalories += activity.calories
        dailyTrackers[normalizedDate] = tracker
    }
    
    func removeActivity(_ activity: Activity) {
        let normalizedDate = normalizeDate(selectedDate)
        guard var tracker = dailyTrackers[normalizedDate] else { return }
        if let index = tracker.activities.firstIndex(where: { $0.id == activity.id }) {
            let removedActivity = tracker.activities.remove(at: index)
            tracker.totalCalories -= removedActivity.calories
            dailyTrackers[normalizedDate] = tracker
        }
    }
    
    var totalProtein: Int { currentTracker?.totalProtein ?? 0 }
    var totalCarbs: Int { currentTracker?.totalCarbs ?? 0 }
    var totalFats: Int { currentTracker?.totalFats ?? 0 }
    
    private func saveDailyTrackers() {
        do {
            let encoded = try JSONEncoder().encode(dailyTrackers)
            UserDefaults.standard.set(encoded, forKey: "DailyTrackers")
        } catch {
            print("DEBUG: Failed to save daily trackers: \(error)")
        }
    }
    
    static func loadDailyTrackers() -> [Date: DailyTracker] {
        guard let data = UserDefaults.standard.data(forKey: "DailyTrackers") else { return [:] }
        do {
            let decoded = try JSONDecoder().decode([Date: DailyTracker].self, from: data)
            return decoded
        } catch {
            print("DEBUG: Failed to load daily trackers: \(error)")
            return [:]
        }
    }
    
    static func loadUserData() -> UserData? {
        if let savedData = UserDefaults.standard.data(forKey: "userData") {
            do {
                let decoder = JSONDecoder()
                let userData = try decoder.decode(UserData.self, from: savedData)
                return userData
            } catch {
                return nil
            }
        }
        return nil
    }
    
    private func syncUserData() {
        if let loadedUserData = CalorieViewModel.loadUserData() {
            self.userData = loadedUserData
        }
    }
}
