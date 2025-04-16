//
//  SubscriptionSheet.swift
//  CalAI
//
//  Created by Денис Николаев on 13.03.2025.

import SwiftUI
import StoreKit
import ApphudSDK

struct SubscriptionSheet: View {
    @ObservedObject var viewModel: SubscriptionViewModel
    @Environment(\.dismiss) var dismiss
    @State private var subscriptionPlans: [SubscriptionPlan] = []
    let showCloseButton: Bool 
    @State private var isCloseButtonVisible: Bool = false
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                VStack {
                    VStack(spacing: 0) {
                        ZStack(alignment: .bottom) {
                            Image("payWall")
                                .resizable()
                                .scaledToFill()
                                .frame(maxHeight: geometry.size.height * 0.5)
                                .clipped()
                            LinearGradient(
                                gradient: Gradient(colors: [Color.clear, Color.black.opacity(1)]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .frame(height: geometry.size.height * 0.15)
                            
                            VStack {
                                VStack {
                                    Text("Unreal heights with PRO")
                                        .font(.system(size: min(28, geometry.size.width * 0.07)))
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.center)
                                }
                                .padding(.bottom, 22)
                                
                                VStack(alignment: .leading, spacing: geometry.size.height * 0.015) {
                                    ForEach(["Unlimed Access", "New features", "Access to all function"], id: \.self) { text in
                                        HStack {
                                            Image(systemName: "sparkles")
                                                .foregroundColor(.white)
                                            Text(text)
                                                .foregroundColor(.white)
                                                .font(.system(size: min(16, geometry.size.width * 0.04)))
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.bottom, 34)
                        
                        VStack(spacing: geometry.size.height * 0.02) {
                            ForEach($subscriptionPlans) { $plan in
                                Button(action: {
                                    subscriptionPlans.indices.forEach { subscriptionPlans[$0].isSelected = false }
                                    if let index = subscriptionPlans.firstIndex(where: { $0.id == plan.id }) {
                                        subscriptionPlans[index].isSelected = true
                                        viewModel.selectedSubscription = plan.period == "Year" ? .yearly : .weekly
                                    }
                                }) {
                                    HStack(spacing: 12) {
                                        VStack(alignment: .leading, spacing: 5) {
                                            Text(plan.period)
                                                .foregroundColor(.white)
                                                .font(.system(size: min(17, geometry.size.width * 0.04)))
                                            Text(plan.price)
                                                .foregroundColor(.gray)
                                                .font(.system(size: min(12, geometry.size.width * 0.035)))
                                            + Text(" per week")
                                                .foregroundColor(.gray)
                                                .font(.system(size: min(12, geometry.size.width * 0.035)))
                                        }
                                        .padding(.leading, 28)
                                        Spacer()
                                        VStack(alignment: .trailing, spacing: 5) {
                                            VStack(alignment: .center, spacing: 5) {
                                                Text(plan.price)
                                                    .foregroundColor(.white)
                                                    .font(.system(size: min(17, geometry.size.width * 0.035)))
                                                Text("per week")
                                                    .foregroundColor(.gray)
                                                    .font(.system(size: min(12, geometry.size.width * 0.035)))
                                            }
                                        }
                                        .padding(.trailing, 28)
                                    }
                                    .padding()
                                    .background(Color(hex: "#201F1F"))
                                    .cornerRadius(16)
                                    .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color(hex: "#0FB423"), lineWidth: plan.isSelected ? 2 : 0))
                                    .overlay(
                                        ZStack {
                                            if plan.isSelected, let discount = plan.discountPercentage {
                                                Text("SAVE \(discount)%")
                                                    .foregroundColor(.white)
                                                    .font(.system(size: min(12, geometry.size.width * 0.035)))
                                                    .padding(.horizontal, 10)
                                                    .padding(.vertical, 4)
                                                    .background(Color(hex: "#0FB423"))
                                                    .cornerRadius(8)
                                                    .offset(x: 115, y: -35)
                                            }
                                        }
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        
                        Button(action: { viewModel.purchaseSubscription() }) {
                            Text("Continue")
                                .font(.system(size: min(17, geometry.size.width * 0.045)))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(hex: "#0FB423"))
                                .cornerRadius(32)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, geometry.size.height * 0.03)
                        .disabled(viewModel.isPurchasing)
                        .opacity(viewModel.isPurchasing ? 0.5 : 1.0)
                        
                        HStack {
                            Image(systemName: "clock.arrow.trianglehead.counterclockwise.rotate.90")
                                .foregroundColor(.gray)
                            Text("Cancel Anytime")
                                .foregroundColor(.gray)
                        }
                        .font(.caption)
                        .padding(.top, geometry.size.height * 0.01)
                        
                        HStack(spacing: geometry.size.width * 0.05) {
                            NavigationLink(destination: PrivacyPolicyView()) {
                                Text("Privacy Policy")
                                    .foregroundColor(.gray)
                                    .font(.caption)
                            }
                            Button(action: {
                                viewModel.restorePurchases { success in
                                    if success {
                                        print("Purchases restored successfully")
                                    } else {
                                        print("Failed to restore purchases")
                                    }
                                }
                            }) {
                                Text("Restore Purchases")
                                    .foregroundColor(.gray)
                                    .font(.caption)
                            }
                            NavigationLink(destination: UsagePolicyView()) {
                                Text("Terms of Use")
                                    .foregroundColor(.gray)
                                    .font(.caption)
                            }
                        }
                        .padding(.top, geometry.size.height * 0.03)
                        .padding(.horizontal, 16)
                    }
                }
            }
            .background(Color.black)
            .foregroundColor(.white)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: isCloseButtonVisible && showCloseButton ? Button(action: {
                closePaywall()
            }) {
                Image(systemName: "xmark")
                    .foregroundColor(.white)
            } : nil)
            .edgesIgnoringSafeArea(.all)
            .onAppear {
                load()
                if showCloseButton {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        withAnimation {
                            isCloseButtonVisible = true
                        }
                    }
                }
            }
        }
        .background(Color.black)
    }
    
    private func closePaywall() {
        if let unwrappedPaywall = viewModel.currentPaywall {
            Apphud.paywallClosed(unwrappedPaywall)
        }
        dismiss()
    }
    
    private func load() {
        Apphud.paywallsDidLoadCallback { paywalls, _ in
            guard let paywall = paywalls.first(where: { $0.identifier == "main" }) else {
                print("Paywall 'main' not found")
                return
            }
            Apphud.paywallShown(paywall)
            viewModel.currentPaywall = paywall
            
            let products = paywall.products
            guard !products.isEmpty else {
                print("No available products")
                return
            }
            
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            
            var newPlans: [SubscriptionPlan] = []
            var weeklyPricePerWeek: Double?
            
            for product in products {
                if let skProduct = product.skProduct, skProduct.subscriptionPeriod?.unit == .week {
                    weeklyPricePerWeek = skProduct.price.doubleValue
                    break
                }
            }
            
            for product in products.reversed() {
                guard let skProduct = product.skProduct else { continue }
                formatter.locale = skProduct.priceLocale
                
                let priceString = formatter.string(from: skProduct.price) ?? "\(skProduct.price)"
                let periodUnit = skProduct.subscriptionPeriod?.unit
                
                let priceValue = skProduct.price.doubleValue
                let pricePerWeek: String
                let periodString: String
                var discountPercentage: Int? = nil
                
                switch periodUnit {
                case .year:
                    periodString = "Yearly"
                    let weeksInYear = 52.0
                    let weeklyPrice = priceValue / weeksInYear
                    pricePerWeek = formatter.string(from: NSNumber(value: weeklyPrice)) ?? "\(weeklyPrice)"
                    if let weeklyPrice = weeklyPricePerWeek {
                        let yearlyCostAtWeeklyRate = weeklyPrice * weeksInYear
                        let savings = yearlyCostAtWeeklyRate - priceValue
                        discountPercentage = Int((savings / yearlyCostAtWeeklyRate) * 100)
                    }
                case .month:
                    periodString = "Month"
                    let weeksInMonth = 4.33
                    let weeklyPrice = priceValue / weeksInMonth
                    pricePerWeek = formatter.string(from: NSNumber(value: weeklyPrice)) ?? "\(weeklyPrice)"
                case .week:
                    periodString = "Weekly"
                    pricePerWeek = priceString
                default:
                    periodString = "Week"
                    pricePerWeek = priceString
                }
                
                let plan = SubscriptionPlan(
                    period: periodString,
                    price: priceString,
                    pricePerWeek: "\(pricePerWeek)/week",
                    isSelected: periodUnit == .year,
                    apphudProduct: product,
                    discountPercentage: discountPercentage
                )
                newPlans.append(plan)
                print(plan)
            }
            
            DispatchQueue.main.async {
                self.subscriptionPlans = newPlans
                self.viewModel.products = products
            }
        }
    }
}
