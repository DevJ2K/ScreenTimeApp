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
                let status = center.authorizationStatus
                print( status.description )
//                if status == .authorized {
//                    acceptedScreenTimeAPI = true
//                }
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
                        Task {
                            do {
                                try await center.requestAuthorization(for: .individual)
                                acceptedScreenTimeAPI = true
                            } catch {
                                print("Failed to enroll Aniyah with error: \(error)")
                            }
                        }
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
