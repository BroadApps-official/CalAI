//
//  HeightView.swift
//  CalAI
//
//  Created by Денис Николаев on 13.03.2025.
//

import SwiftUI

struct HeightView: View {
    @ObservedObject var viewModel: UserDataViewModel
    let choose: Bool
    @Environment(\.dismiss) var dismiss
    @State private var selectedHeight: Double = 180.0
    
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
            
            Picker("Choose your height", selection: $selectedHeight) {
                ForEach(150..<220) { height in
                    Text("\(height).0 cm").tag(Double(height))
                }
            }
            .pickerStyle(.wheel)
            .colorScheme(.dark)
            .onChange(of: selectedHeight) { newHeight in
                viewModel.userData.height = newHeight
            }
            
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
    HeightView(viewModel: UserDataViewModel(), choose: true)
}
