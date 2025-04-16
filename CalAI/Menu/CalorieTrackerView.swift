//
//  CalorieTrackerView.swift
//  CalAI
//
//  Created by Денис Николаев on 13.03.2025.
//

import SwiftUI

struct CalorieTrackerView: View {
    @ObservedObject var viewModel: CalorieViewModel
    @Binding var selectedTab: String
    @State private var isSettingsPresented = false
    @State private var showAddEntry = false
    @State private var isSubscriptionSheetPresented = false
    @StateObject private var subscriptionManager = SubscriptionManager()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    DatePickerSection(viewModel: viewModel)
                    CalorieSummary(viewModel: viewModel)
                    MealSection(viewModel: viewModel)
                    ActivitySection(viewModel: viewModel)
                }
                .padding()
                .padding(.bottom, 60)
            }
            .navigationTitle("Calorie Tracker")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    HStack(spacing: 8) {
                        if !subscriptionManager.hasSubscription {
                            Button(action: {
                                impactFeedback.impactOccurred()
                                isSubscriptionSheetPresented = true
                            }) {
                                HStack(spacing: 4) {
                                    Text("GET PRO")
                                        .font(.system(size: 15, weight: .bold))
                                    Image(systemName: "flame.fill")
                                        .font(.system(size: 17, weight: .bold))
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(LinearGradient(gradient: Gradient(colors: [Color(hex: "#0FB423"), Color(hex: "#0EC1E9")]), startPoint: .leading, endPoint: .trailing))
                                .cornerRadius(32)
                                .foregroundColor(.white)
                            }
                        }
                        
                        Button(action: {
                            isSettingsPresented = true
                            impactFeedback.impactOccurred()
                        }) {
                            Image(systemName: "gearshape.fill")
                                .foregroundColor(.white)
                                .imageScale(.large)
                                .background(
                                    Circle()
                                        .fill(.gray)
                                        .frame(width: 32, height: 32)
                                )
                        }
                        .fullScreenCover(isPresented: $isSettingsPresented) {
                            SettingsView()
                        }
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                CustomTabBar(selectedTab: $selectedTab, showAddEntry: $showAddEntry)
            }
            .overlay(
                Group {
                    if showAddEntry {
                        AddEntryView(isPresented: $showAddEntry, category: "Other")
                            .shadow(radius: 10)
                    }
                }
            )
            .fullScreenCover(isPresented: $isSubscriptionSheetPresented) {
                SubscriptionSheet(viewModel: SubscriptionViewModel(), showCloseButton: true)
            }
        }
        .task {
            await subscriptionManager.checkSubscriptionStatus()
        }
    }
}
