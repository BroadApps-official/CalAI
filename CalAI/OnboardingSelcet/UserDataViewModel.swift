//
//  UserDataViewModel.swift
//  CalAI
//
//  Created by Денис Николаев on 13.03.2025.
//

import Foundation

class UserDataViewModel: ObservableObject {
    @Published var userData: UserData {
        didSet {
            saveData()
        }
    }
    @Published var currentStep: Int = 0
    
    let steps: [String] = [
        "Choose your gender",
        "Select the date of birth",
        "Choose your weight",
        "Choose your height",
        "Select a goal",
        "Select the target weight",
        "Select your activity"
    ]
    
    var isCurrentStepValid: Bool {
        switch currentStep {
        case 0: return userData.gender != nil
        case 1: return userData.dateOfBirth != nil
        case 2: return userData.weight != nil
        case 3: return userData.height != nil
        case 4: return userData.goal != nil
        case 5: return userData.targetWeight != nil
        case 6: return userData.activityLevel != nil
        default: return false
        }
    }
    
    init() {
        self.userData = UserDataViewModel.loadData() ?? UserData()
    }
    
    func nextStep() {
        if currentStep < steps.count - 1 && isCurrentStepValid {
            currentStep += 1
        }
    }
    
    func previousStep() {
        if currentStep > 0 {
            currentStep -= 1
        }
    }
    
    func saveData() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(userData)
            UserDefaults.standard.set(data, forKey: "userData")
            print("Data saved: \(userData)")
            NotificationCenter.default.post(name: NSNotification.Name("UserDataUpdated"), object: nil)
        } catch {
            print("Failed to save data: \(error)")
        }
    }
    
    static func loadData() -> UserData? {
        if let savedData = UserDefaults.standard.data(forKey: "userData") {
            do {
                let decoder = JSONDecoder()
                let userData = try decoder.decode(UserData.self, from: savedData)
                return userData
            } catch {
                print("Failed to load data: \(error)")
                return nil
            }
        }
        return nil
    }
}
