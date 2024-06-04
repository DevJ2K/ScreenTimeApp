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

class ScreenTimeModel: ObservableObject {
    static let shared = ScreenTimeModel()
    let store = ManagedSettingsStore()
    
    // Pour gérer le début et la fin d'une surveillance.
    let deviceActivityCenter = DeviceActivityCenter()
    
    let userDefaultsKey = "ScreenTimeSelection"
    
    var activitySelection = FamilyActivitySelection()
//    var activitySelection = FamilyActivitySelection() {
//        willSet {
//            //            print ("got here \(newValue)")
//            let applications = newValue.applicationTokens
//            let categories = newValue.categoryTokens
//            let webCategories = newValue.webDomainTokens
//            //            print("Number of applications : \(applications.count)")
////            store.shield.applications = applications.isEmpty ? nil : applications
////            store.shield.applicationCategories = ShieldSettings.ActivityCategoryPolicy.specific(categories, except: Set())
////            store.shield.webDomains = webCategories
//        }
//    }
    
    private init(){}
    
    private func applyRestrictions(for selection: FamilyActivitySelection) {
            let applications = selection.applicationTokens
            let categories = selection.categoryTokens
            let webCategories = selection.webDomainTokens
            
            store.shield.applications = applications.isEmpty ? nil : applications
            store.shield.applicationCategories = categories.isEmpty ? nil : ShieldSettings.ActivityCategoryPolicy.specific(categories, except: Set())
            store.shield.webDomains = webCategories.isEmpty ? nil : webCategories
        }
    
    func startContinuousMonitoring() {
        applyRestrictions(for: activitySelection)
        
        let events: [DeviceActivityEvent.Name: DeviceActivityEvent] = [
            .encouraged: DeviceActivityEvent(
                applications: activitySelection.applicationTokens,
                categories: activitySelection.categoryTokens,
                webDomains: activitySelection.webDomainTokens,
                threshold: DateComponents(second: 10))
        ]
        do {
            
            //            let applications = activitySelection.applicationTokens
            //            let categories = activitySelection.categoryTokens
            //            let webCategories = activitySelection.webDomainTokens
            ////            print("Number of applications : \(applications.count)")
            //            store.shield.applications = applications.isEmpty ? nil : applications
            //            store.shield.applicationCategories = ShieldSettings.ActivityCategoryPolicy.specific(categories, except: Set())
            //            store.shield.webDomains = webCategories
            
            
            try deviceActivityCenter.startMonitoring(.activity, during: schedule, events: events)
            print("The continuous restriction is up !")
        } catch {
            print("Unexpected error while starting monitoring : \(error).")
        }
    }
    
    func stopContinuousMonitoring() {
        deviceActivityCenter.stopMonitoring()
        store.clearAllSettings()
        print("The continuous restriction has been stopped !")
    }
    
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


class MyMonitorExtension: DeviceActivityMonitor {
    let store = ManagedSettingsStore()
    
    
    // You can use the `store` property to shield apps when an interval starts, ends, or meets a threshold.
    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
        
        
        // Shield selected applications.
        let model = ScreenTimeModel.shared
        let applications = model.activitySelection.applications as Set<Application>
        store.shield.applications = applications.isEmpty ? nil : applications
    }
}
    

let schedule = DeviceActivitySchedule(
    intervalStart: DateComponents(hour: 0, minute: 0, second: 0), intervalEnd: DateComponents(hour: 23, minute: 59), repeats: true, warningTime: nil
)

//extension DeviceActivityName {
//    static let daily = Self("daily")
//}
extension DeviceActivityName {
    static let activity = Self("activity")
}

extension DeviceActivityEvent.Name {
    static let encouraged = Self("encouraged")
}
