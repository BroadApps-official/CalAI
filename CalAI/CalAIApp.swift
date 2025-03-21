//
//  CalAIApp.swift
//  CalAI
//
//  Created by Денис Николаев on 13.03.2025.
//

import SwiftUI
import ApphudSDK

@main
struct CalAIApp: App {
    @StateObject private var appState = AppStateManager()
    
    init() {
        Apphud.start(apiKey: "app_eJtrDChcs2bFhK8gPHA93m2mAnFnCP") { result in
            let apphudUserId = Apphud.userID()
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .preferredColorScheme(.dark)
                .sheet(isPresented: $appState.shouldShowFeedback) {
                    FeedbackView()
                        .environmentObject(appState)
                }
        }
    }
}
