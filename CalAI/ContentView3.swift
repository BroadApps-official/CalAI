//
//  ContentView.swift
//  CalAI
//
//  Created by Денис Николаев on 14.03.2025.

let impactFeedback = UIImpactFeedbackGenerator(style: .medium)

import SwiftUI

struct ContentView3: View {
    @StateObject private var viewModel = RecipeViewModel()
    @StateObject private var subscriptionManager = SubscriptionManager()
    @State private var isSettingsPresented = false
    @Binding var selectedTab: String
    @EnvironmentObject var calorieViewModel: CalorieViewModel
    @State private var showAddEntry = false
    @State private var isSubscriptionSheetPresented = false
    
    private let categoryImages: [String: String] = [
        "Breakfast": "breakfast",
        "Lunch": "lunch",
        "Dinner": "dinner",
        "Snack": "snack",
        "Other": "other"
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    ForEach(viewModel.categories) { category in
                        NavigationLink(destination: RecipeListView(viewModel: viewModel, category: category.name)) {
                            HStack {
                                Image(categoryImages[category.name] ?? "defaultIcon")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 72, height: 72)
                                Text(category.name)
                                    .foregroundColor(.white)
                                Spacer()
                                Text("\(category.count)")
                                    .foregroundColor(.white)
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.green)
                            }
                            .padding()
                            .background(Color(hex: "#000000").opacity(0.4))
                            .cornerRadius(28)
                        }
                    }
                }
                .padding()
                .background(Color(hex: "#FFFFFF").opacity(0.1))
                .cornerRadius(32)
            }
            .padding(.horizontal, 16)
            .navigationTitle("Recipes")
            .toolbarBackground(Color.black, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
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
                SubscriptionSheet(viewModel: SubscriptionViewModel())
            }
            .onAppear {
                viewModel.reloadData()
            }
        }
        .environmentObject(viewModel)
        .environmentObject(calorieViewModel)
        .task {
            await subscriptionManager.checkSubscriptionStatus()
        }
    }
}
