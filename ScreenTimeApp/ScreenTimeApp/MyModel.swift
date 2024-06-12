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

// Pour faire communiquer les targets entre elles, il faut passer par un app groups.
let appGroup = "group.fr.devj2k.ScreenTimeApp"

// Le nom de la clé où sera sauvegardé les activités sélectionnées.
let activitySelectionKey = "ScreenTimeSelectionKey"

struct StructSelectionCount {
    var applications: Int
    var categories: Int
    var webDomain: Int
}

// Pour sauvegarder les activités sélectionnées.
func saveActivitySelection(activitySelection: FamilyActivitySelection) {
    if let sharedDefaults = UserDefaults(suiteName: appGroup) {
        
        let encoder = JSONEncoder()
        sharedDefaults.set(try? encoder.encode(activitySelection), forKey: activitySelectionKey)
    }
}

// Pour récupérer les activités sauvegardées.
func loadActivitySelection() -> FamilyActivitySelection {
    if let sharedDefaults = UserDefaults(suiteName: appGroup) {
        guard let value = sharedDefaults.data(forKey: activitySelectionKey) else { return FamilyActivitySelection() }
        let decoder = JSONDecoder()
        let data = try? decoder.decode(FamilyActivitySelection.self, from: value)
        return data ?? FamilyActivitySelection()
    }
    return FamilyActivitySelection()
}

// Pour connaître le nombre d'applications, catégories et webDomain sélectionnées.
func initSelectionCount() -> StructSelectionCount {
    let activitySelection = loadActivitySelection()
    return StructSelectionCount(
        applications: activitySelection.applications.count,
        categories: activitySelection.categories.count,
        webDomain: activitySelection.webDomains.count)
}

func getBooleanOf(keyName: String) -> Bool {
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

class ScreenTimeModel: ObservableObject {
    static let shared = ScreenTimeModel()
    @Published var selectionCount = initSelectionCount()
    @Published var isModeRunning = getBooleanOf(keyName: "isModeRunning")
    
    let store = ManagedSettingsStore(named: .restricted)
    
    let deviceActivityCenter = DeviceActivityCenter()
    
    // Chaque fois que l'utilisateur changera les applications sélectionnées, cette méthode sera appelé.
    var activitySelection = loadActivitySelection() {
        willSet {
            selectionCount.applications = newValue.applications.count
            selectionCount.categories = newValue.categories.count
            selectionCount.webDomain = newValue.webDomains.count
            saveActivitySelection(activitySelection: newValue)
        }
    }
    
    private init(){}
    
    // Stocke les applications dans store.shield. pour appliquer les restrictions.
    func applyRestrictions() {
        let selection = loadActivitySelection()
        
        let applications = selection.applicationTokens
        let categories = selection.categoryTokens
        let webCategories = selection.webDomainTokens
        
        store.shield.applications = applications.isEmpty ? nil : applications
        store.shield.applicationCategories = categories.isEmpty ? nil : ShieldSettings.ActivityCategoryPolicy.specific(categories, except: Set())
        store.shield.webDomains = webCategories.isEmpty ? nil : webCategories
        
        if let sharedDefaults = UserDefaults(suiteName: appGroup) {
            let value = sharedDefaults.bool(forKey: "isInStrictMode")
            if (value == true) {
                store.application.denyAppRemoval = true
            }
        }
        print("The restrictions have been successfully added !")
    }
    
    // Retire toutes les restrictions et intervalles.
    func removeRestrictions() {
        deviceActivityCenter.stopMonitoring()
        store.clearAllSettings()
        store.application.denyAppRemoval = false
        saveBooleanOf(keyName: "isModeRunning", value: false)
        isModeRunning = false
        print("Restrictions successfully removed !")
    }
    
    // Pour lancer la restriction pour une durée de "hours" et "minutes"
    func startTimerMode(hours: Int, minutes: Int) -> String {
        let now = Date()
        let calendar = Calendar.current
        
        let intervalStartDate = calendar.date(byAdding: .minute, value: -30, to: now)!
        let intervalStartComponents = calendar.dateComponents([.hour, .minute, .second], from: intervalStartDate)
        
        
        let intervalEndDate = calendar.date(byAdding: .minute, value: ((hours * 60) + minutes), to: now)!
//        let intervalEndDate = calendar.date(byAdding: .second, value: 5, to: now)!
        let intervalEndComponents = calendar.dateComponents([.hour, .minute, .second], from: intervalEndDate)
        
        let schedule = DeviceActivitySchedule(
            intervalStart: intervalStartComponents, intervalEnd: intervalEndComponents, repeats: false, warningTime: nil
        )
        do {
            try deviceActivityCenter.startMonitoring(.restricted, during: schedule)
            print("The continuous restriction is up !")
            return ""
        } catch {
            print("Unexpected error while starting timer monitor: \(error).")
            return "Unexpected error while starting timer monitor: \(error)."
        }
    }
    
    // Pour lancer la restriction de manière récurrente.
    func startProgrammedMode(start: Date, end: Date) -> String {
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
            return ""
        } catch {
            print("Unexpected error while starting programmed monitor : \(error).")
            return "Unexpected error while starting programmed monitor : \(error)."
        }
    }
    
    // Lancer indéfiniment les restrictions
    func startContinuousMode() {
        applyRestrictions()
        print("MODE : Continuous : Start")
    }
}

extension DeviceActivityName {
    static let restricted = Self("restricted")
}

extension ManagedSettingsStore.Name {
    static let restricted = Self("restricted")
}
