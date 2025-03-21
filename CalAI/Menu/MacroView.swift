//
//  MacroView.swift
//  CalAI
//
//  Created by Денис Николаев on 13.03.2025.
//

import SwiftUI

struct MacroView: View {
    let icon: String
    let value: Int
    let goal: Int
    let label: String
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .stroke(Color.green.opacity(0.3), lineWidth: 6)
                    .frame(width: 70, height: 70)
                
                Circle()
                    .trim(from: 0.0, to: min(CGFloat(value) / CGFloat(goal), 1.0))
                    .stroke(Color.green, lineWidth: 6)
                    .rotationEffect(Angle(degrees: -90))
                    .frame(width: 70, height: 70)
                
                Image(icon)
                    .frame(width: 30, height: 30)
            }
            
            Text("\(value)/\(goal)g")
                .font(.caption)
                .foregroundColor(.white)
            
            Text(label)
                .font(.caption2)
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
    }
}
