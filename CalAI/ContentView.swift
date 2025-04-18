//
//  ContentView.swift
//  CalAI
//
//  Created by Денис Николаев on 13.03.2025.
//

import SwiftUI

struct ContentView: View {
    @State private var reloadTrigger = UUID()
    var body: some View {
        SplashScreenView()
            .id(reloadTrigger)
            .onReceive(NotificationCenter.default.publisher(for: .reloadApp)) { _ in
                reloadTrigger = UUID()
            }
    }
}

#Preview {
    ContentView()
}
