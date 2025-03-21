//
//  SettingsView.swift
//  CalAI
//
//  Created by Денис Николаев on 14.03.2025.
//

import WebKit

struct PrivacyPolicyView: View {
    var body: some View {
        WebView(url: URL(string: "https://docs.google.com/document/d/14Rf-GahEW-qDn8QULJF1qw-JuasxKUZzca0FNSs7jJo/edit?usp=sharing")!)
            .navigationTitle("Privacy Policy")
            .navigationBarTitleDisplayMode(.inline)
    }
}

struct UsagePolicyView: View {
    var body: some View {
        WebView(url: URL(string: "https://docs.google.com/document/d/1B4ciHS_6fVja3HXT9JeIXZ7tGRb3rku2yySENwOjFgE/edit?usp=sharing")!)
            .navigationTitle("Usage Policy")
            .navigationBarTitleDisplayMode(.inline)
    }
}

struct WebView: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.load(URLRequest(url: url))
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        
    }
}
import SwiftUI
import StoreKit
import UserNotifications

struct SettingsRow: View {
    let title: String
    let icon: String
    var detail: String? = nil
    var isToggle: Bool = false
    var action: (() -> Void)? = nil
    var toggleAction: ((Bool) -> Void)? = nil
    var showDisclosureIndicator: Bool = true
    
    @State private var toggleState: Bool = false
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(Color(hex: "#0EC1E9"))
                .frame(width: 24, height: 24)
            Text(title)
                .foregroundColor(.white)
                .font(.system(size: 16))
            Spacer()
            if let detail = detail {
                Text(detail)
                    .foregroundColor(.gray)
                    .font(.system(size: 14))
            }
            if isToggle {
                Toggle("", isOn: $toggleState)
                    .labelsHidden()
                    .toggleStyle(SwitchToggleStyle(tint: .white))
                    .onChange(of: toggleState) { newValue in
                        toggleAction?(newValue)
                    }
            } else if showDisclosureIndicator {
                Image(systemName: "chevron.right")
                    .foregroundColor(Color(hex: "#0EC1E9"))
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onTapGesture {
            action?()
        }
    }
}

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @StateObject private var subscriptionManager = SubscriptionManager()
    @StateObject private var subscriptionViewModel = SubscriptionViewModel()
    @Environment(\.dismiss) var dismiss
    @State private var showProfile = false
    @State private var isSubscriptionSheetPresented = false
    @State private var navigationPath = NavigationPath()
    
    private enum Destination: Hashable {
        case contactUs
        case privacyPolicy
        case usagePolicy
    }
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                List {
                    Section {
                        Button(action: {
                            impactFeedback.impactOccurred()
                            showProfile = true
                        }) {
                            Text("Edit Profile")
                                .foregroundColor(.white)
                                .font(.system(size: 17))
                                .frame(maxWidth: .infinity, minHeight: 44)
                                .background(Color(hex: "#0FB423").opacity(0.12))
                                .cornerRadius(32)
                        }
                        .listRowInsets(EdgeInsets())
                    }
                    
                    Section(header: Text("Support us").foregroundColor(.gray)) {
                        SettingsRow(title: "Rate app", icon: "star.fill", action: {
                            viewModel.requestReview()
                        })
                        SettingsRow(title: "Share with friends", icon: "square.and.arrow.up", action: {
                            viewModel.shareApp()
                        })
                    }
                    
                    Section(header: Text("Purchases & Actions").foregroundColor(.gray)) {
                        SettingsRow(title: "Upgrade plan", icon: "sparkles") {
                            isSubscriptionSheetPresented = true
                        }
                        SettingsRow(title: "Notifications", icon: "bell", isToggle: true, toggleAction: {
                            viewModel.toggleNotifications($0)
                        })
                        SettingsRow(title: "Clear cache",
                                    icon: "trash",
                                    detail: viewModel.cacheSize,
                                    action: {
                            viewModel.showClearCacheConfirmation()
                        })
                        SettingsRow(title: "Restore purchases", icon: "arrow.clockwise.icloud", action:{
                            isSubscriptionSheetPresented = true
                        })
                    }
                    
                    Section(header: Text("Info & legal").foregroundColor(.gray)) {
                        SettingsRow(title: "Contact us", icon: "text.bubble", action: {
                            openEmail()
                        })
                        
                        SettingsRow(title: "Privacy Policy", icon: "folder.badge.person.crop", action: {
                            navigationPath.append(Destination.privacyPolicy)
                        })
                        
                        SettingsRow(title: "Usage Policy", icon: "doc.text", action: {
                            navigationPath.append(Destination.usagePolicy)
                        })
                    }
                    
                    Text("App Version: 1.0.0")
                        .font(.footnote)
                        .listRowBackground(Color.black)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .listStyle(InsetGroupedListStyle())
                .background(Color.black)
                .alert("Clear Cache", isPresented: $viewModel.showClearCacheAlert) {
                    Button("Cancel", role: .cancel) { }
                    Button("Clear", role: .destructive) {
                        viewModel.clearCache()
                    }
                } message: {
                    Text("The cached files of your photo will be deleted from your phone's memory. But your download history will be retained.")
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.green)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !subscriptionManager.isLoading {
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
                    }
                }
            }
            .navigationDestination(for: Destination.self) { destination in
                switch destination {
                case .contactUs:
                    Text("Contact Us Placeholder")
                        .navigationTitle("Contact Us")
                        .navigationBarTitleDisplayMode(.inline)
                case .privacyPolicy:
                    PrivacyPolicyView()
                case .usagePolicy:
                    UsagePolicyView()
                }
            }
            .fullScreenCover(isPresented: $showProfile) {
                NavigationStack {
                    ProfileView(viewModel: UserDataViewModel())
                }
            }
            .fullScreenCover(isPresented: $isSubscriptionSheetPresented) {
                SubscriptionSheet(viewModel: SubscriptionViewModel())
            }
        }
        .task {
            await subscriptionManager.checkSubscriptionStatus()
        }
    }
    private func openEmail() {
        let email = "cetinsedat999@hotmail.com"
        let subject = "Contact Us from YourApp"
        let mailtoString = "mailto:\(email)?subject=\(subject)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        if let mailtoURL = URL(string: mailtoString) {
            UIApplication.shared.open(mailtoURL) { success in
                if !success {
                    print("Failed to open email client. Ensure an email account is set up on the device.")
                }
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
