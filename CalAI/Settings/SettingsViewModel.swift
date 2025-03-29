//
//  SettingsViewModel.swift
//  CalAI
//
//  Created by Денис Николаев on 14.03.2025.
//

import SwiftUI
import StoreKit
import UserNotifications

class SettingsViewModel: ObservableObject {
    @Published var isNotificationsEnabled: Bool = false
    @Published var cacheSize: String = "0 MB"
    @Published var showClearCacheAlert: Bool = false
    
    init() {
        checkNotificationStatus()
        updateCacheSize()
    }
    
    func requestReview() {
        guard let windowScene = UIApplication.shared
                .connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first else {
            print("Не удалось получить UIWindowScene")
            return
        }
        SKStoreReviewController.requestReview(in: windowScene)
    }
    
    func shareApp() {
        let appURL = URL(string: "https://apps.apple.com/us/app/6743544003") ?? nil
        let activityController = UIActivityViewController(activityItems: [appURL ?? "Share CalAI Fitness App"], applicationActivities: nil)
        
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = scene.windows.first?.rootViewController {
            rootViewController.present(activityController, animated: true, completion: nil)
        }
    }
    
    func toggleNotifications(_ enabled: Bool) {
        if enabled {
            requestNotificationPermission()
        } else {
            disableNotifications()
        }
    }
    
    func showClearCacheConfirmation() {
        showClearCacheAlert = true
    }
    
    func clearCache() {
        URLCache.shared.removeAllCachedResponses()
        
        let fileManager = FileManager.default
        let tempDirectory = NSTemporaryDirectory()
        do {
            let filePaths = try fileManager.contentsOfDirectory(atPath: tempDirectory)
            for filePath in filePaths {
                try fileManager.removeItem(atPath: tempDirectory + filePath)
            }
        } catch {
            print("Error clearing cache: \(error.localizedDescription)")
        }
        
        DispatchQueue.main.async {
            self.updateCacheSize()
        }
    }
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                self.isNotificationsEnabled = granted
                if !granted && error != nil {
                    print("Notification permission denied: \(error?.localizedDescription ?? "")")
                }
            }
        }
    }
    
    func disableNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        isNotificationsEnabled = false
    }
    
    func checkNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isNotificationsEnabled = (settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional)
            }
        }
    }
    
    func updateCacheSize() {
        let cache = URLCache.shared.currentDiskUsage
        let tempSize = getTemporaryDirectorySize()
        let totalSize = Double(cache + tempSize) / (1024.0 * 1024.0)
        cacheSize = String(format: "%.1f MB", totalSize)
    }
    
    private func getTemporaryDirectorySize() -> Int {
        let fileManager = FileManager.default
        let tempDirectory = NSTemporaryDirectory()
        var totalSize = 0
        
        do {
            let filePaths = try fileManager.contentsOfDirectory(atPath: tempDirectory)
            for filePath in filePaths {
                let fullPath = tempDirectory + filePath
                let attributes = try fileManager.attributesOfItem(atPath: fullPath)
                if let fileSize = attributes[.size] as? Int {
                    totalSize += fileSize
                }
            }
        } catch {
            print("Error calculating temp directory size: \(error.localizedDescription)")
        }
        return totalSize
    }
}
