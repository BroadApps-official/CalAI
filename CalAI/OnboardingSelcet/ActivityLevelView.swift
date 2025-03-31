//
//  ActivityLevelView.swift
//  CalAI
//
//  Created by Денис Николаев on 31.03.2025.
//


//
//  ActivityLevelView.swift
//  CalAI
//
//  Created by Денис Николаев on 13.03.2025.
//

import SwiftUI

struct ActivityLevelView: View {
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
                    viewModel.userData.activityLevel = .sedentary
                }) {
                    Text("Sedentary")
                        .foregroundColor(.white)
                        .font(.system(size: 18))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(viewModel.userData.activityLevel == .sedentary ? Color(hex: "#0FB423") : Color(white: 0.15))
                        .cornerRadius(10)
                }
                
                Button(action: {
                    impactFeedback.impactOccurred()
                    viewModel.userData.activityLevel = .light
                }) {
                    Text("Light")
                        .foregroundColor(.white)
                        .font(.system(size: 18))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(viewModel.userData.activityLevel == .light ? Color(hex: "#0FB423") : Color(white: 0.15))
                        .cornerRadius(10)
                }
                
                Button(action: {
                    impactFeedback.impactOccurred()
                    viewModel.userData.activityLevel = .moderate
                }) {
                    Text("Moderate")
                        .foregroundColor(.white)
                        .font(.system(size: 18))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(viewModel.userData.activityLevel == .moderate ? Color(hex: "#0FB423") : Color(white: 0.15))
                        .cornerRadius(10)
                }
                
                Button(action: {
                    impactFeedback.impactOccurred()
                    viewModel.userData.activityLevel = .active
                }) {
                    Text("Active")
                        .foregroundColor(.white)
                        .font(.system(size: 18))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(viewModel.userData.activityLevel == .active ? Color(hex: "#0FB423") : Color(white: 0.15))
                        .cornerRadius(10)
                }
                
                Button(action: {
                    impactFeedback.impactOccurred()
                    viewModel.userData.activityLevel = .veryActive
                }) {
                    Text("Very Active")
                        .foregroundColor(.white)
                        .font(.system(size: 18))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(viewModel.userData.activityLevel == .veryActive ? Color(hex: "#0FB423") : Color(white: 0.15))
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
    ActivityLevelView(viewModel: UserDataViewModel(), choose: true)
}