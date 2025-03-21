//
//  GoalView.swift
//  CalAI
//
//  Created by Денис Николаев on 13.03.2025.
//

import SwiftUI

struct GoalView: View {
    @ObservedObject var viewModel: UserDataViewModel
    let choose: Bool
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            if choose {
                Text(viewModel.steps[viewModel.currentStep])
                    .foregroundColor(.white)
                    .font(.system(size: 28, weight: .bold))
                    .padding()
                
                Text("Add the data")
                    .foregroundColor(.gray)
                    .font(.system(size: 17))
                    .padding(.bottom, 6)
            }
            
            Spacer()
            
            VStack(spacing: 16) {
                Button(action: {
                    impactFeedback.impactOccurred()
                    viewModel.userData.goal = .loseWeight
                }) {
                    Text("Lose weight")
                        .foregroundColor(.white)
                        .font(.system(size: 18))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(viewModel.userData.goal == .loseWeight ? Color(hex: "#0FB423") : Color(white: 0.15))
                        .cornerRadius(10)
                }
                
                Button(action: {
                    impactFeedback.impactOccurred()
                    viewModel.userData.goal = .maintainWeight
                }) {
                    Text("Maintain weight")
                        .foregroundColor(.white)
                        .font(.system(size: 18))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(viewModel.userData.goal == .maintainWeight ? Color(hex: "#0FB423") : Color(white: 0.15))
                        .cornerRadius(10)
                }
                
                Button(action: {
                    impactFeedback.impactOccurred()
                    viewModel.userData.goal = .gainWeight
                }) {
                    Text("Gain weight")
                        .foregroundColor(.white)
                        .font(.system(size: 18))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(viewModel.userData.goal == .gainWeight ? Color(hex: "#0FB423") : Color(white: 0.15))
                        .cornerRadius(10)
                }
            }
            .padding(.horizontal, 16)
            
            Spacer()
            
            if choose {
                HStack(spacing: 8) {
                    Button(action: {
                        impactFeedback.impactOccurred()
                        dismiss()
                    }) {
                        Text("Back")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(hex: "#0FB423").opacity(0.2))
                            .cornerRadius(32)
                            .font(.system(size: 17, weight: .bold))
                    }
                    
                    Button(action: {
                        impactFeedback.impactOccurred()
                        viewModel.saveData()
                        dismiss()
                    }) {
                        Text("Save")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(hex: "#0FB423"))
                            .cornerRadius(32)
                            .font(.system(size: 17, weight: .bold))
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}

#Preview {
    GoalView(viewModel: UserDataViewModel(), choose: true)
}
