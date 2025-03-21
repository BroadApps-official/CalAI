//
//  SplashScreenView.swift
//  CalAI
//
//  Created by Денис Николаев on 19.03.2025.
//

import SwiftUI

struct SplashScreenView: View {
    @State private var isLoading = true
    @State private var isFirstLaunch = false
    @State private var navigateToOnboarding = false
    @State private var navigateToMain = false
    @StateObject private var calorieViewModel = CalorieViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    Spacer()
                    Image("appicon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 160, height: 160)
                        .cornerRadius(40)
                    
                    Spacer()
                    
                   
                }
                
                NavigationLink(
                    destination: OnboardingView()
                        .navigationBarBackButtonHidden(true),
                    isActive: $navigateToOnboarding
                ) {
                    EmptyView()
                }
            }
            .onAppear {
                checkFirstLaunch()
                startLoading()
            }
            .fullScreenCover(isPresented: $navigateToMain) {
                HomeView()
            }
        }
    }
    
    private func checkFirstLaunch() {
        if UserDefaults.standard.bool(forKey: "hasLaunchedBefore") {
            isFirstLaunch = false
        } else {
            isFirstLaunch = true
            UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
        }
    }
    
    private func startLoading() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            isLoading = false
            if isFirstLaunch {
                navigateToOnboarding = true
            } else {
                navigateToMain = true
            }
        }
    }
}

#Preview {
    SplashScreenView()
}
