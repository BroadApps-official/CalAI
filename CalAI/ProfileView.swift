//
//  ProfileView.swift
//  CalAI
//
//  Created by Денис Николаев on 14.03.2025.
//

import SwiftUI

struct ProfileView: View {
    @ObservedObject var viewModel: UserDataViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 16) {
                VStack(spacing: 10) {
                    NavigationLink(destination: GenderView(viewModel: viewModel, choose: true).navigationBarBackButtonHidden(true)) {
                        ProfileRow(title: "Gender", value: viewModel.userData.gender?.rawValue ?? "Not set")
                    }
                    
                    NavigationLink(destination: DateOfBirthView(viewModel: viewModel, choose: true).navigationBarBackButtonHidden(true)) {
                        ProfileRow(title: "Date of birth", value: formattedDate(viewModel.userData.dateOfBirth))
                    }
                    
                    NavigationLink(destination: WeightView(viewModel: viewModel, choose: true).navigationBarBackButtonHidden(true)) {
                        ProfileRow(title: "Weight", value: formattedValue(viewModel.userData.weight, unit: "kg"))
                    }
                    
                    NavigationLink(destination: HeightView(viewModel: viewModel, choose: true).navigationBarBackButtonHidden(true)) {
                        ProfileRow(title: "Height", value: formattedValue(viewModel.userData.height, unit: "cm"))
                    }
                    
                    NavigationLink(destination: GoalView(viewModel: viewModel, choose: true).navigationBarBackButtonHidden(true)) {
                        ProfileRow(title: "Goal", value: viewModel.userData.goal?.rawValue ?? "Not set")
                    }
                    
                    NavigationLink(destination: TargetWeightView(viewModel: viewModel, choose: true).navigationBarBackButtonHidden(true)) {
                        ProfileRow(title: "Target weight", value: formattedValue(viewModel.userData.targetWeight, unit: "kg"))
                    }
                }
                .padding(.horizontal, 16)

                VStack(alignment: .center){
                    Text("A specialized plan is being developed based \n on your data.")
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .font(.system(size: 14))
                        .padding(.bottom, 20)
                    Spacer()
                }
            }
        }
        .navigationTitle("Edit Profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
                .foregroundColor(.green)
            }
        }
    }
    
    private func formattedValue(_ value: Double?, unit: String) -> String {
        guard let value = value else { return "Not set" }
        return "\(String(format: "%.1f", value)) \(unit)"
    }
    
    private func formattedDate(_ date: Date?) -> String {
        guard let date = date else { return "Not set" }
        return date.formatted(date: .long, time: .omitted)
    }
}

struct ProfileRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.gray)
                .font(.system(size: 16))
            Spacer()
            Text(value)
                .foregroundColor(.green)
                .font(.system(size: 16))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color(hex: "#FFFFFF").opacity(0.08))
                .cornerRadius(10)  
        }
        .padding()
        .background(Color(white: 0.15))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.2), radius: 3, x: 0, y: 2)
    }
}

#Preview {
    NavigationView {
        ProfileView(viewModel: UserDataViewModel())
    }
}
