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
    @State private var immediateDuration = Date()
    
    @State private var hours: Int = 0
    @State private var minutes: Int = 5
    
    @Environment (\.colorScheme) private var colorScheme
    
    init() {
        UIDatePicker.appearance().minuteInterval = 5
    }
    var body: some View {
        NavigationStack {
            VStack {
                
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
                            .foregroundStyle(colorScheme == .dark ? .white : .black)
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
                            HStack {
                                Picker("hours", selection: $hours) {
                                    ForEach(0..<24, id: \.self) { i in
//                                        HStack {
//                                            Spacer()
                                            Text("\(i)").tag(i)
                                                .multilineTextAlignment(.trailing)
//                                        }
                                    }
                                }
                                .pickerStyle(WheelPickerStyle())
                                .labelsHidden()
                                Text("hrs")
                                    .bold()
                                Picker("minutes", selection: $minutes) {
                                    ForEach(stride(from: 0, to: 60, by: 5).map({$0}), id: \.self) { i in
                                        Text("\(i)").tag(i)
                                    }
                                }
                                .pickerStyle(WheelPickerStyle())
                                Text("mns")
                                    .bold()
                            }
                            
//                            DatePicker(selection: $immediateDuration, displayedComponents: .hourAndMinute) {
//                                Text("Duration")
//                            }
                        } else if (selectedMode == "programmed") {
                            Text("Programmed")
                        } else if (selectedMode == "continuous") {
                            Text("Continuous")
                        }
                    } header: {
                        Text("Horaire")
                            .foregroundStyle(colorScheme == .dark ? .white : .black)
                            .bold()
                    }
                }
                .scrollContentBackground(.hidden)
                .navigationTitle("ScreenTimeApp")
                Button {
                    print("Start !")
                } label: {
                    Text("Démarrer")
                        .foregroundStyle(colorScheme == .dark ? .black : .white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(RoundedRectangle(cornerRadius: 32)
                            .fill(colorScheme == .dark ? .white : .black))
                        .padding()
                }
                .ignoresSafeArea(.all)
            }
            .background(colorScheme == .light ? .gray.opacity(0.1) : .black)
        }
    }
}

#Preview {
    ContentView()
}
