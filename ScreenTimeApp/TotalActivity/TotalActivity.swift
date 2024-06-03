//
//  TotalActivity.swift
//  TotalActivity
//
//  Created by Théo Ajavon on 03/06/2024.
//

import DeviceActivity
import SwiftUI

@main
struct TotalActivity: DeviceActivityReportExtension {
    var body: some DeviceActivityReportScene {
        // Create a report for each DeviceActivityReport.Context that your app supports.
        TotalActivityReport { totalActivity in
            TotalActivityView(totalActivity: totalActivity)
        }
        // Add more reports here...
    }
}
