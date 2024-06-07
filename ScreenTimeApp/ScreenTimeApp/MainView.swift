//
//  MainView.swift
//  ScreenTimeApp
//
//  Created by Théo Ajavon on 03/06/2024.
//

import SwiftUI

func getBooleanOf(keyName: String) -> Bool {
    // Accéder aux UserDefaults avec le nom de suite "isModeRunning"
    if let sharedDefaults = UserDefaults(suiteName: appGroup) {
        let value = sharedDefaults.bool(forKey: keyName)
        return value
    }
    return false
}

func saveBooleanOf(keyName: String, value: Bool) {
    if let sharedDefaults = UserDefaults(suiteName: appGroup) {
        sharedDefaults.set(value, forKey: keyName)
    }
}

struct MainView: View {
    @State private var selectedMode = "continuous"
    @State private var appsToLock = "0"
    
    @State private var alertErrorMessage = ""
    @State private var alertErrorTitle = ""
    @State private var showAlert = false
    
    @State private var isModeRunning = getBooleanOf(keyName: "isModeRunning")
    
    // Variable du mode strict
    @State private var strictMode = getBooleanOf(keyName: "isInStrictMode")
    
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
        UIDatePicker.appearance().minuteInterval = 1
    }
    
    func getStartText() -> String {
        if (isModeRunning) {
            return ("Stop")
        } else {
            return selectedMode == "programmed" ? "Programmer" : "Démarrer"
        }
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
                                
                                HStack {
                                    Image(systemName: "square.grid.2x2")
                                    Text("\(model.selectionCount.applications)")
                                }
                                .font(.caption)
                                .padding(.vertical, 4)
                                .padding(.horizontal, 4)
                                .background(RoundedRectangle(cornerRadius: 6).opacity(0.2))
                                HStack {
                                    Image(systemName: "folder")
                                    Text("\(model.selectionCount.categories)")
                                }
                                .font(.caption)
                                .padding(.vertical, 4)
                                .padding(.horizontal, 4)
                                .background(RoundedRectangle(cornerRadius: 6).opacity(0.2))
                                HStack {
                                    Image(systemName: "globe")
                                    Text("\(model.selectionCount.webDomain)")
                                }
                                .font(.caption)
                                .padding(.vertical, 4)
                                .padding(.horizontal, 4)
                                .background(RoundedRectangle(cornerRadius: 6).opacity(0.2))
                                
                                
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.secondary)
                                    .font(.caption)
                                    .bold()
                            }
                            .padding(.vertical, 6)
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
                        .onChange(of: strictMode) { newValue in
                            saveBooleanOf(keyName: "isInStrictMode", value: strictMode)
                        }
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
                    
                    if (isModeRunning) {
                        if (strictMode == false) {
                            model.removeRestrictions()
                            isModeRunning = false
                            saveBooleanOf(keyName: "isModeRunning", value: isModeRunning)
                            print("All restrictions has been removed !")
                        } else {
                            print("Cannot stop because the strict mode is on.")
                            alertErrorTitle = "Strict Mode"
                            alertErrorMessage = "Vous ne pouvez pas désactiver la restriction tant que le strict mode est activé."
                            showAlert = true
                        }
                    } else {
                        alertErrorMessage = ""
                        switch selectedMode {
                        case "immediate":
                            print("STARTING MODE : Immediate")
                            alertErrorMessage = model.startTimerMode(hours: immediateHours, minutes: immediateMinutes)
                        case "programmed":
                            print("STARTING MODE : Programmed")
                            alertErrorMessage = model.startProgrammedMode(start: programmedStart, end: programmedEnd)
                        case "continuous":
                            print("STARTING MODE : Continuous")
                            model.startContinuousMode()
                        default:
                            alertErrorMessage = "Mode not found."
                            print("Mode not found")
                        }
                        if (alertErrorMessage == "") {
                            isModeRunning = true
                            saveBooleanOf(keyName: "isModeRunning", value: isModeRunning)
                        } else {
                            alertErrorTitle = "Mode Error"
                            showAlert = true
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
                .alert(isPresented: $showAlert) {
                    Alert(title: Text(alertErrorTitle), message: Text(alertErrorMessage), dismissButton: .default(Text("Ok")))
                }
            }
            .background(colorScheme == .light ? .gray.opacity(0.1) : .black)
        }
    }
}

#Preview {
    MainView()
}
