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

class ScreenTimeModel: ObservableObject {
    static let shared = ScreenTimeModel()
    let store = ManagedSettingsStore(named: .restricted)
    
    // Pour gérer le début et la fin d'une surveillance.
    let deviceActivityCenter = DeviceActivityCenter()
    
    
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
    
    func startTimerMode(hours: Int, minutes: Int) {
        let now = Date()
        let calendar = Calendar.current
        
        let intervalStartComponents = calendar.dateComponents([.hour, .minute, .second], from: now)

        let intervalEndDate = calendar.date(byAdding: .minute, value: ((hours * 60) + minutes), to: now)!
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
    
    func startProgrammedMode(start: Date, end: Date) {
        // Minimum interval : 15minutes
        // Maximum interval : 1 week
        let calendar = Calendar.current
        
        let intervalStartComponents = calendar.dateComponents([.hour, .minute, .second], from: start)
        let intervalEndComponents = calendar.dateComponents([.hour, .minute, .second], from: end)
        
        let schedule = DeviceActivitySchedule(
            intervalStart: intervalStartComponents, intervalEnd: intervalEndComponents, repeats: true, warningTime: nil
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
