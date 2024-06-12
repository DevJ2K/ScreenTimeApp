//
//  MainView.swift
//  ScreenTimeApp
//
//  Created by Théo Ajavon on 03/06/2024.
//

import SwiftUI
import ManagedSettings
import Combine

class UserDefaultsObserver: ObservableObject {
    private let keyName = "isModeRunning"

    @Published var value: Bool = false

    private var cancellable: AnyCancellable?

    init() {
        if let sharedDefaults = UserDefaults(suiteName: appGroup) {
            value = sharedDefaults.bool(forKey: keyName)
        }

        cancellable = NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification)
            .sink { [weak self] _ in
                self?.updateValue()
            }
    }

    private func updateValue() {
        if let sharedDefaults = UserDefaults(suiteName: appGroup) {
            DispatchQueue.main.async {
                self.value = sharedDefaults.bool(forKey: self.keyName)
                print("Value has been updated in UserDefaultsObserver !")
            }
        }
    }
}

struct MainView: View {
    @State private var selectedMode = "immediate"
    @State private var appsToLock = "0"
    @StateObject private var userDefaultsObserver = UserDefaultsObserver()
    
    @State private var alertErrorMessage = ""
    @State private var alertErrorTitle = ""
    @State private var showAlert = false
    @State private var cancelStrictChange = false
    
    @State private var isModeRunning = getBooleanOf(keyName: "isModeRunning")
    
    // Variable du mode strict
    @State private var strictMode = getBooleanOf(keyName: "isInStrictMode")
    @State private var showingConfirmationStrictMode = false
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
            return ("Arrêt de blocage")
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
                            if (cancelStrictChange == true) {
                                cancelStrictChange = false
                                return
                            }
                            if (newValue == false && isModeRunning == true) {
                                strictMode = true
                                alertErrorTitle = "Strict Mode"
                                alertErrorMessage = "Vous ne pouvez pas désactiver le mode strict tant qu'une restriction est activée."
                                showAlert = true
                                cancelStrictChange = true
                            } else if (newValue == true) {
                                showingConfirmationStrictMode = true
                            } else {
                                saveBooleanOf(keyName: "isInStrictMode", value: strictMode)
                                let store = ManagedSettingsStore(named: .restricted)
                                store.application.denyAppRemoval = false
                            }
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
                        if (strictMode == false || selectedMode == "continuous") {
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
                .confirmationDialog("Active strict mode", isPresented: $showingConfirmationStrictMode) {
                    Button("Activer") {
                        saveBooleanOf(keyName: "isInStrictMode", value: strictMode)
                        let store = ManagedSettingsStore(named: .restricted)
                        if (strictMode == true && isModeRunning == true) {
                            store.application.denyAppRemoval = true
                        } else {
                            store.application.denyAppRemoval = false
                        }
                    }
                    Button("Annuler", role: .cancel) {
                        strictMode = false
                    }
                } message: {
                    Text("Êtes-vous sûr d'activer le mode strict ? Une fois le mode immédiat ou programmée lancé vous ne pourrez désactiver le mode strict.")
                }
            }
            .background(colorScheme == .light ? .gray.opacity(0.1) : .black)
            .onChange(of: userDefaultsObserver.value) { newValue in
//                print("Mode changing !")
                print("New value of isModeRunning : \(newValue)")
                isModeRunning = getBooleanOf(keyName: "isModeRunning")
            }
        }
    }
}

#Preview {
    MainView()
}
