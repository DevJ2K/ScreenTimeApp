//
//  MyModel.swift
//  ScreenTimeApp
//
//  Created by Théo Ajavon on 04/06/2024.
//

import Foundation
import FamilyControls
import DeviceActivity
import ManagedSettings


let appGroup = "group.fr.devj2k.ScreenTimeApp"
let activitySelectionKey = "ScreenTimeSelectionKey"

func saveActivitySelection(activitySelection: FamilyActivitySelection) {
    if let sharedDefaults = UserDefaults(suiteName: appGroup) {
        
        let encoder = JSONEncoder()
        sharedDefaults.set(try? encoder.encode(activitySelection), forKey: activitySelectionKey)
    }
}

func loadActivitySelection() -> FamilyActivitySelection {
    if let sharedDefaults = UserDefaults(suiteName: appGroup) {
        guard let value = sharedDefaults.data(forKey: activitySelectionKey) else { return FamilyActivitySelection() }
        let decoder = JSONDecoder()
        let data = try? decoder.decode(FamilyActivitySelection.self, from: value)
        return data ?? FamilyActivitySelection()
    }
    return FamilyActivitySelection()
}


//func saveSelection(selection: FamilyActivitySelection) {
//    let defaults = UserDefaults.standard
//    let encoder = JSONEncoder()
//
//    defaults.set(try? encoder.encode(selection), forKey: userDefaultsKey)
//}
//
//func loadSavedSelection() -> FamilyActivitySelection? {
//    let defaults = UserDefaults.standard
//    let decoder = JSONDecoder()
//
//    guard let data = defaults.data(forKey: userDefaultsKey) else { return nil }
//    return try? decoder.decode(FamilyActivitySelection.self, from: data)
//}


class ScreenTimeModel: ObservableObject {
    static let shared = ScreenTimeModel()
    let store = ManagedSettingsStore(named: .restricted)
    
    // Pour gérer le début et la fin d'une surveillance.
    let deviceActivityCenter = DeviceActivityCenter()
    
    let activitySelectionKey = "ScreenTimeSelectionKey"
    
        var activitySelection = loadActivitySelection() {
            willSet {
                saveActivitySelection(activitySelection: newValue)
            }
        }
    
    private init(){}
    
    func applyRestrictions() {
        let selection = loadActivitySelection()
        
        let applications = selection.applicationTokens
        let categories = selection.categoryTokens
        let webCategories = selection.webDomainTokens
        
        store.shield.applications = applications.isEmpty ? nil : applications
        store.shield.applicationCategories = categories.isEmpty ? nil : ShieldSettings.ActivityCategoryPolicy.specific(categories, except: Set())
        store.shield.webDomains = webCategories.isEmpty ? nil : webCategories
        
        print("The restrictions have been successfully added !")
    }
    
    func removeRestrictions() {
        deviceActivityCenter.stopMonitoring()
        store.clearAllSettings()
        print("Restrictions successfully removed !")
    }
    
    func startTimerMode() {
        
        // Obtenez la date actuelle
        let now = Date()

        // Créez un DateComponents pour le début de l'intervalle en utilisant la date actuelle
        let calendar = Calendar.current
        let intervalStartComponents = calendar.dateComponents([.hour, .minute, .second], from: now)

        // Ajoutez 1h30 à la date actuelle pour obtenir la fin de l'intervalle
        let intervalEndDate = calendar.date(byAdding: .minute, value: 90, to: now)!
        let intervalEndComponents = calendar.dateComponents([.hour, .minute, .second], from: intervalEndDate)

        let schedule = DeviceActivitySchedule(
            intervalStart: intervalStartComponents, intervalEnd: intervalEndComponents, repeats: false, warningTime: nil
        )
        do {
            try deviceActivityCenter.startMonitoring(.restricted, during: schedule)
            print("The continuous restriction is up !")
        } catch {
            print("Unexpected error while starting timer monitor: \(error).")
        }
    }
    
    func startProgrammedMode() {
        // Minimum interval : 15minutes
        // Maximum interval : 1 week
        let schedule = DeviceActivitySchedule(
            intervalStart: DateComponents(hour: 9, minute: 30, second: 40), intervalEnd: DateComponents(hour: 10, minute: 50, second: 0), repeats: true, warningTime: nil
        )
        do {
            try deviceActivityCenter.startMonitoring(.restricted, during: schedule)
            print("The continuous restriction is up !")
        } catch {
            print("Unexpected error while starting programmed monitor : \(error).")
        }
    }
    
    func startContinuousMode() {
        applyRestrictions()
        print("MODE : Continuous : Start")
    }
    
    func stopContinuousMode() {
        removeRestrictions()
        print("MODE : Continuous : Stop")
    }
}

extension DeviceActivityName {
    static let restricted = Self("restricted")
}

extension ManagedSettingsStore.Name {
    static let restricted = Self("restricted")
}
