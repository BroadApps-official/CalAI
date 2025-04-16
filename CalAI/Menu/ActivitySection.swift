//
//  ActivitySection.swift
//  CalAI
//
//  Created by Денис Николаев on 13.03.2025.
//

import SwiftUI

struct ActivitySection: View {
    @ObservedObject var viewModel: CalorieViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Activity")
                .font(.headline)
            if viewModel.activities().isEmpty {
                VStack {
                    EmptyActivityView()
                }
            } else {
                VStack {
                    ForEach(viewModel.activities()) { activity in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(activity.name)
                                    .foregroundColor(.white)
                                Text("\(activity.calories) kcal")
                                    .foregroundColor(.green)
                            }
                            Spacer()
                            Text(activity.duration)
                                .foregroundColor(.cyan)
                                .font(.caption)
                        }
                        .padding()
                        .background(Color.black.opacity(0.4))
                        .cornerRadius(28)
                        .contextMenu() {
                            Button(role: .destructive) {
                                viewModel.removeActivity(activity)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            .tint(.red)
                        }
                    }
                }
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(32)
            }
        }
    }
}

#Preview {
   // HomeView()
}
