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
import Combine


class ScreenTimeModel: ObservableObject {
    static let shared = ScreenTimeModel()
    let store = ManagedSettingsStore()
    
    // Pour gérer le début et la fin d'une surveillance.
    let center = DeviceActivityCenter()
    
    let userDefaultsKey = "ScreenTimeSelection"
    
    var activitySelection = FamilyActivitySelection()
    
    private init(){}
    
    
//    func saveSelection(selection: FamilyActivitySelection) {
//        let defaults = UserDefaults.standard
//        let encoder = JSONEncoder()
//        
//        defaults.set(try? encoder.encode(selection), forKey: userDefaultsKey)
//    }
//    
//    func loadSavedSelection() -> FamilyActivitySelection? {
//        let defaults = UserDefaults.standard
//        let decoder = JSONDecoder()
//        
//        guard let data = defaults.data(forKey: userDefaultsKey) else { return nil }
//        return try? decoder.decode(FamilyActivitySelection.self, from: data)
//    }
}


//class MyModel: ObservableObject {
//    static let shared = MyModel()
//    let store = ManagedSettingsStore()
//    let center = DeviceActivityCenter()
//    
//    private init() {}
//    
//    var selectionToDiscourage = FamilyActivitySelection() {
//        willSet {
////            print ("got here \(newValue)")
//            let applications = newValue.applicationTokens
//            let categories = newValue.categoryTokens
//            let webCategories = newValue.webDomainTokens
////            print("Number of applications : \(applications.count)")
//            store.shield.applications = applications.isEmpty ? nil : applications
//            store.shield.applicationCategories = ShieldSettings.ActivityCategoryPolicy.specific(categories, except: Set())
//            store.shield.webDomains = webCategories
//            
////            print(applications)
//            
////            store.clearAllSettings()
//            
//        }
//    }
//    
//    func initiateMonitoring() {
//        print("Setting schedule...")
//        print(selectionToDiscourage.applicationTokens)
//        let events: [DeviceActivityEvent.Name: DeviceActivityEvent] = [
//            .encouraged: DeviceActivityEvent(
//                applications: selectionToDiscourage.applicationTokens,
//                threshold: DateComponents(second: 10)
//            )
//        ]
//        
//        do {
//            try center.startMonitoring(.daily, during: schedule,events: events)
//        }
//        catch {
//            print ("Could not start monitoring \(error)")
//        }
//        
////        store.appStore.maximumRating = 200
//        print("Setting schedule Complete!")
//    }
//    
//    func stopMonitoring(){
//        print("Setting schedule Stop")
//        center.stopMonitoring()
//        store.clearAllSettings()
//    }
//}


let schedule = DeviceActivitySchedule(
    intervalStart: DateComponents(hour: 0, minute: 0), intervalEnd: DateComponents(hour: 23, minute: 59), repeats: true, warningTime: nil
)

extension DeviceActivityName {
    static let daily = Self("daily")
}

extension DeviceActivityEvent.Name {
    static let encouraged = Self("encouraged")
}
