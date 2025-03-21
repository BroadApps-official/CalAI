//
//  FeedbackView.swift
//  CalAI
//
//  Created by Денис Николаев on 13.03.2025.

import SwiftUI
import StoreKit
import UIKit

class AppStateManager: ObservableObject {
    @Published var shouldShowFeedback = false
    private let videoGenerationKey = "videoGenerationCount"
    private let appLaunchKey = "appLaunchCount"
    private let hasRatedKey = "hasRated"
    
    init() {
        registerDefaults()
        incrementAppLaunchCount()
        updateFeedbackState()
    }
    
    private func registerDefaults() {
        UserDefaults.standard.register(defaults: [
            videoGenerationKey: 0,
            appLaunchKey: 0,
            hasRatedKey: false
        ])
    }
    
    func incrementVideoGeneration() {
        let currentCount = UserDefaults.standard.integer(forKey: videoGenerationKey)
        UserDefaults.standard.set(currentCount + 1, forKey: videoGenerationKey)
        updateFeedbackState()
    }
    
    private func incrementAppLaunchCount() {
        let currentCount = UserDefaults.standard.integer(forKey: appLaunchKey)
        UserDefaults.standard.set(currentCount + 1, forKey: appLaunchKey)
        updateFeedbackState()
    }
    
    func markAsRated() {
        UserDefaults.standard.set(true, forKey: hasRatedKey)
        shouldShowFeedback = false
    }
    
    private func updateFeedbackState() {
        let videoCount = UserDefaults.standard.integer(forKey: videoGenerationKey)
        let launchCount = UserDefaults.standard.integer(forKey: appLaunchKey)
        let hasRated = UserDefaults.standard.bool(forKey: hasRatedKey)
        
        shouldShowFeedback = !hasRated && (
            videoCount == 3 ||
            videoCount == 6 ||
            launchCount == 3
        )
    }
}

// FeedbackView (без изменений)
struct FeedbackView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var appState: AppStateManager
    let appStoreId = "6742832930"
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 20) {
                Spacer()
                
                Image("heart")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 260, height: 260)
                
                Text("Do you like our app?")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                
                Text("Please rate our app so we can improve it for \n you and make it even cooler")
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                
                HStack(spacing: 15) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("No")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(hex: "#0FB423").opacity(0.2))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .font(.system(size: 17, weight: .bold))
                    }
                    
                    Button(action: {
                        openAppStoreReview()
                        appState.markAsRated()
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Yes!")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(hex: "#0FB423"))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .font(.system(size: 17, weight: .bold))
                    }
                }
                .padding(.horizontal, 30)
                
                Spacer()
            }
            
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.title2)
                            .foregroundColor(Color(hex: "#0FB423"))
                            .padding()
                    }
                }
                Spacer()
            }
        }
    }
    
    private func openAppStoreReview() {
        guard let url = URL(string: "https://apps.apple.com/app/id\(appStoreId)?action=write-review") else { return }
        UIApplication.shared.open(url, options: [:]) { _ in }
    }
}
