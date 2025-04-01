//
//  OnboardingView.swift
//  CalAI
//
//  Created by Денис Николаев on 13.03.2025.


import SwiftUI

struct OnboardingView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                TabView(selection: $viewModel.currentPage) {
                    ForEach(viewModel.steps.indices, id: \.self) { index in
                        OnboardingStepView(step: viewModel.steps[index], index: index, viewModel: viewModel)
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .ignoresSafeArea(edges: .top)
                
                Spacer()
            }
            .background(Color(hex: "#131313"))
            .ignoresSafeArea(edges: .top)
        }
    }
}

#Preview {
    OnboardingView()
}



