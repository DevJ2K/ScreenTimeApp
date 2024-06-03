//
//  TotalActivityView.swift
//  TotalActivity
//
//  Created by Théo Ajavon on 03/06/2024.
//

import SwiftUI

struct TotalActivityView: View {
    let totalActivity: String
    
    var body: some View {
        Text(totalActivity)
    }
}

// In order to support previews for your extension's custom views, make sure its source files are
// members of your app's Xcode target as well as members of your extension's target. You can use
// Xcode's File Inspector to modify a file's Target Membership.
#Preview {
    TotalActivityView(totalActivity: "1h 23m")
}
