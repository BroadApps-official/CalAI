//
//  CalAIApp.swift
//  CalAI
//
//  Created by Денис Николаев on 13.03.2025.
//

import SwiftUI
import ApphudSDK
import AppTrackingTransparency
import AdSupport

@main
struct CalAIApp: App {
    @StateObject private var appState = AppStateManager()
    
    init() {
        Apphud.start(apiKey: "app_eJtrDChcs2bFhK8gPHA93m2mAnFnCP") { result in
            let apphudUserId = Apphud.userID()
        }
        fetchIDFA()
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

func fetchIDFA() {
    if #available (iOS 14.5, *) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            ATTrackingManager.requestTrackingAuthorization { status in
                guard status == .authorized else { return }
                let idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
                Apphud.setDeviceIdentifiers(idfa: idfa, idfv: UIDevice.current.identifierForVendor?.uuidString)
            }
        }
    }
}
