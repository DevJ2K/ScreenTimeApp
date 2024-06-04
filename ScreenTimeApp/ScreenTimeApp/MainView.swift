//
//  MainView.swift
//  ScreenTimeApp
//
//  Created by Théo Ajavon on 03/06/2024.
//

import SwiftUI

struct MainView: View {
    @State private var selectedMode = "continuous"
    @State private var appsToLock = "0"
    
    @State private var isContinuousRunning = false
    
    // Variable du mode strict
    @State private var strictMode = false
    
    // La durée lorsqu'on sélectionne le mode immédiat | Par défaut 0 hrs et 5 mns
    @State private var immediateHours: Int = 0
    @State private var immediateMinutes: Int = 5
    @State private var isImmediateSheetOpened = false
    
    // Début et fin lorsqu'on sélectionne le mode programmé | Par défaut Début &&
    @State private var programmedStart: Date = {
        var components = DateComponents()
        components.hour = 9
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }()
    
    @State private var programmedEnd: Date = {
        var components = DateComponents()
        components.hour = 17
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }()
    
    @Environment (\.colorScheme) private var colorScheme
    
    @StateObject var model = ScreenTimeModel.shared
    
    @State private var appSelectionModal = false

    init() {
        UIDatePicker.appearance().minuteInterval = 5
    }
    
    func getStartText() -> String {
        if (selectedMode == "programmed") {
            return ("Programmer")
        }
        return (isContinuousRunning ? "Stop" : "Démarrer")
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                
                List {
                    Section {
                        Button(action: {
                            appSelectionModal = true
                        }, label: {
                            HStack {
                                Text("Apps & Sites web")
                                Spacer()
    //                            Text("\(immediateHours)h \(immediateMinutes)m")
    //                                .foregroundStyle(.secondary)
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.secondary)
                                    .font(.caption)
                                    .bold()
                            }
    //                        .padding(.vertical, 12)
                            .foregroundStyle(colorScheme == .dark ? .white : .black)
                        })
                        .familyActivityPicker(isPresented: $appSelectionModal, selection: $model.activitySelection)
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
                            Button(action: {
                                isImmediateSheetOpened = true
                            }, label: {
                                HStack {
                                    Text("Durée")
                                    Spacer()
                                    Text("\(immediateHours)h \(immediateMinutes)m")
                                        .foregroundStyle(.secondary)
                                    Image(systemName: "chevron.right")
                                        .foregroundStyle(.secondary)
                                        .font(.caption)
                                        .bold()
                                }
                                .padding(.vertical, 12)
                                .foregroundStyle(colorScheme == .dark ? .white : .black)
                            })
                            .sheet(isPresented: $isImmediateSheetOpened) {
                                TimePickerView(selectedHours: $immediateHours, selectedMinutes: $immediateMinutes, isImmediateSheetOpened: $isImmediateSheetOpened)
                                    .presentationDetents([.medium])
                                    .presentationDragIndicator(.visible)
//                                    .interactiveDismissDisabled()
                                
                            }
                        } else if (selectedMode == "programmed") {
                            DatePicker(selection: $programmedStart, displayedComponents: .hourAndMinute) {
                                Text("Début")
                            }
                            .padding(.vertical, 4)
                            DatePicker(selection: $programmedEnd, displayedComponents: .hourAndMinute) {
                                Text("Fin")
                            }
                            .padding(.vertical, 4)
                        } else if (selectedMode == "continuous") {}
                    } header: {
                        Text("Horaire")
                            .foregroundStyle(colorScheme == .dark ? .white : .black)
                            .bold()
                    }
                }
                .scrollContentBackground(.hidden)
                .navigationTitle("ScreenTimeApp")
                Button {
                    if (selectedMode == "continuous") {
                        if (isContinuousRunning) {
//                            model.stopMonitoring()
                            isContinuousRunning = false
                        } else {
//                            model.initiateMonitoring()
                            isContinuousRunning = true
                        }
                    }
                } label: {
                    Text(getStartText())
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
    MainView()
}
