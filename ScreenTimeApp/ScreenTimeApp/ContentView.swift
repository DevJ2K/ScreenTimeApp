//
//  ContentView.swift
//  ScreenTimeApp
//
//  Created by Théo Ajavon on 03/06/2024.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedMode = "immediate"
    @State private var appsToLock = "0"
    @State private var strictMode = false
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Picker(selection: $appsToLock) {
                        Text("Empty").tag("0")
                        Text("Empty").tag("1")
                    } label: {
                        Text("Apps & Sites web")
                    }
                    .pickerStyle(.navigationLink)
                    Toggle(isOn: $strictMode, label: {
                        HStack {
                            Text("Mode Strict")
                            Spacer()
                            HStack(spacing: 2) {
                                Image(systemName: "bolt.fill")
                                Text("PLUS")
                            }
                            .font(.caption)
                            .foregroundStyle(.white)
                            .padding(6)
                            .background(RoundedRectangle(cornerRadius: 10)
                                .fill(LinearGradient(gradient: Gradient(colors: [.cyan, .purple, .pink, .orange ]), startPoint: .topLeading, endPoint: .bottomTrailing)
                                     ))
                            .bold()
                            .padding(.horizontal, 4)
                        }
                    })
                } header: {
                    Text("Bloquer")
                        .foregroundStyle(.black)
                        .bold()
                }
                
                Section {
                    Picker("Mode", selection: $selectedMode) {
                        Text("Immédiate").tag("immediate")
                        Text("Programmée").tag("programmed")
                        Text("En continue").tag("continuous")
                    }
                    .pickerStyle(.segmented)
                    
                    if (selectedMode == "immediate") {
                        Text("Duration")
                    } else if (selectedMode == "programmed") {
                        Text("Programmed")
                    } else if (selectedMode == "continuous") {
                        Text("Continuous")
                    }
                } header: {
                    Text("Horaire")
                        .foregroundStyle(.black)
                        .bold()
                }
            }
            .navigationTitle("ScreenTimeApp")
            Button {
                print("Start !")
            } label: {
                Text("Démarrer")
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 32)
                        .fill(.black))
                    .padding()
            }
        }
//        .padding()
    }
}

#Preview {
    ContentView()
}
