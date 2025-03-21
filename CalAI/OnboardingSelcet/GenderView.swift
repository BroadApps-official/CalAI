//
//  GenderView.swift
//  CalAI
//
//  Created by Денис Николаев on 13.03.2025.
//

import SwiftUI

struct GenderButton: View {
    let gender: Gender
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            withAnimation(.easeInOut) {
                action()
            }
        }) {
            VStack(spacing: 8) {
                Image(gender == .men ? "Men" : "Women")
                    .resizable()
                    .scaledToFit()
                    .font(.title2)
                    .frame(width: 100, height: 100)
                
                Text(gender.rawValue)
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .medium))
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? Color.green : Color.gray.opacity(0.3))
                    .frame(width: 175, height: 175, alignment: .center)
            )
        }
    }
}

struct GenderView: View {
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
            
            HStack(spacing: 8) {
                ForEach(Gender.allCases, id: \.self) { gender in
                    GenderButton(
                        gender: gender,
                        isSelected: viewModel.userData.gender == gender,
                        action: { viewModel.userData.gender = gender }
                    )
                }
            }
            .padding(.horizontal)
            
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
    }
}

#Preview {
    GenderView(viewModel: UserDataViewModel(), choose: true)
}
