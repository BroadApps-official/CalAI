//
//  OnboardingChoose.swift
//  CalAI
//
//  Created by Денис Николаев on 14.03.2025.
//

import SwiftUI

struct OnboardingChoose: View {
    @StateObject private var viewModel = UserDataViewModel()
    @State private var isOnboardingComplete = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                VStack {
                    Text(viewModel.steps[viewModel.currentStep])
                        .foregroundColor(.white)
                        .font(.system(size: 28, weight: .bold))
                        .padding()
                    
                    Text("Add the data")
                        .foregroundColor(.gray)
                        .font(.system(size: 17))
                        .padding(.bottom, 6)
                    
                    Spacer()
                    
                    switch viewModel.currentStep {
                    case 0: GenderView(viewModel: viewModel, choose: false)
                    case 1: DateOfBirthView(viewModel: viewModel, choose: false)
                    case 2: WeightView(viewModel: viewModel, choose: false)
                    case 3: HeightView(viewModel: viewModel, choose: false)
                    case 4: GoalView(viewModel: viewModel, choose: false)
                    case 5: TargetWeightView(viewModel: viewModel, choose: false)
                    default: EmptyView()
                    }
                    
                    Spacer()
                    
                    HStack {
                        ForEach(0..<viewModel.steps.count, id: \.self) { index in
                            Circle()
                                .frame(width: 8, height: 8)
                                .foregroundColor(index == viewModel.currentStep ? .green : .gray)
                        }
                    }
                    
                    HStack(spacing: 8) {
                        if viewModel.currentStep > 0 {
                            Button(action: {
                                impactFeedback.impactOccurred()
                                viewModel.previousStep()
                            }) {
                                Text("Back")
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color(hex: "#0FB423").opacity(0.2))
                                    .cornerRadius(32)
                                    .font(.system(size: 17, weight: .bold))
                            }
                        }
                        
                        Button(action: {
                            impactFeedback.impactOccurred()
                            if viewModel.currentStep == viewModel.steps.count - 1 {
                                viewModel.saveData()
                                isOnboardingComplete = true
                            } else {
                                viewModel.nextStep()
                            }
                        }) {
                            Text(viewModel.currentStep == viewModel.steps.count - 1 ? "Save" : "Next")
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(viewModel.isCurrentStepValid ? Color(hex: "#0FB423") : Color.gray)
                                .cornerRadius(32)
                                .font(.system(size: 17, weight: .bold))
                        }
                        .disabled(!viewModel.isCurrentStepValid)
                    }
                    .padding(.horizontal, 16)
                }
            }
            .navigationBarHidden(true)
            .fullScreenCover(isPresented: $isOnboardingComplete) {
                HomeView()
            }
        }
    }
}

#Preview {
    OnboardingChoose()
}
