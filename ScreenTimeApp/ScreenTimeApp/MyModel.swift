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
        let schedule = DeviceActivitySchedule(
            intervalStart: DateComponents(hour: 10, minute: 35, second: 30), intervalEnd: DateComponents(hour: 23, minute: 59, second: 59), repeats: true, warningTime: nil
        )
        do {
            try deviceActivityCenter.startMonitoring(.restricted, during: schedule)
            print("The continuous restriction is up !")
        } catch {
            print("Unexpected error while starting monitoring : \(error).")
        }
    }
    
    func startProgrammedMode() {
        // Minimum interval : 15minutes
        // Maximum interval : 1 week
        let schedule = DeviceActivitySchedule(
            intervalStart: DateComponents(hour: 9, minute: 30, second: 40), intervalEnd: DateComponents(hour: 10, minute: 44, second: 0), repeats: true, warningTime: nil
        )
        do {
            try deviceActivityCenter.startMonitoring(.restricted, during: schedule)
            print("The continuous restriction is up !")
        } catch {
            print("Unexpected error while starting monitoring : \(error).")
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

//let schedule = DeviceActivitySchedule(
//    intervalStart: DateComponents(hour: 0, minute: 0, second: 0), intervalEnd: DateComponents(hour: 23, minute: 59, second: 59), repeats: true, warningTime: nil
//)


extension DeviceActivityName {
    static let restricted = Self("restricted")
}

extension ManagedSettingsStore.Name {
    static let restricted = Self("restricted")
}
