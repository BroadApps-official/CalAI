//
//  CalorieSummary.swift
//  CalAI
//
//  Created by Денис Николаев on 13.03.2025.
//

import SwiftUI

struct CalorieSummary: View {
    @ObservedObject var viewModel: CalorieViewModel
    
    var body: some View {
        VStack(spacing: 8) {
            VStack(spacing: 10) {
                Text("\(viewModel.totalCaloriesConsumed()) / \(viewModel.calorieGoal) \n calories left")
                    .font(.title)
                    .bold()
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .frame(height: 12)
                            .foregroundColor(Color.gray.opacity(0.3))
                            .cornerRadius(5)
                        Rectangle()
                            .frame(
                                width: min(
                                    max(0, geometry.size.width * CGFloat(viewModel.totalCaloriesConsumed()) / CGFloat(viewModel.calorieGoal)),
                                    geometry.size.width
                                ),
                                height: 10
                            )
                            .foregroundColor(Color.green)
                            .cornerRadius(5)
                    }
                }
                .frame(height: 12)
            }
            .padding()
            .background(Color(hex: "#000000").opacity(0.4))
            .cornerRadius(28)
            
            HStack(spacing: 40) {
                MacroView(icon: "protein", value: viewModel.totalProtein, goal: viewModel.proteinGoal, label: "protein")
                MacroView(icon: "carbs", value: viewModel.totalCarbs, goal: viewModel.carbsGoal, label: "carbs")
                MacroView(icon: "fats", value: viewModel.totalFats, goal: viewModel.fatsGoal, label: "fats")
            }
            .padding()
            .background(Color(hex: "#000000").opacity(0.4))
            .cornerRadius(28)
        }
        .padding(12)
        .background(Color(hex: "#FFFFFF").opacity(0.1))
        .cornerRadius(32)
        .foregroundColor(.white)
    }
}
