//
//  ContentView.swift
//  ScreenTimeApp
//
//  Created by Théo Ajavon on 03/06/2024.
//

import SwiftUI
import FamilyControls

struct ContentView: View {
    let center = AuthorizationCenter.shared
    @State private var acceptedScreenTimeAPI = false
    
    func checkAuthorizationStatus() {
        Task {
            do {
                try await center.requestAuthorization(for: .individual)
                let status = center.authorizationStatus
                print(status)
                if status == .approved {
                    acceptedScreenTimeAPI = true
                }
            } catch {
                print("Failed to enroll with error: \(error)")
            }
        }
    }
    
    var body: some View {
        Group {
            
            if (acceptedScreenTimeAPI) {
                MainView()
            } else {
                VStack {
                    Text("Merci d'accepter l'API ScreenTime pour continuer.")
                        .multilineTextAlignment(.center)
                    Button(action: {
                        checkAuthorizationStatus()
                    }, label: {
                        Text("Accepter")
                    })
                }
            }
        }
        .onAppear {
            checkAuthorizationStatus()
        }
    }
}

#Preview {
    ContentView()
}
