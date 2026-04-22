//
//  MediBotApp.swift
//  MediBot
//
//  Created by Zonish Sheikh
//

import SwiftUI

// Entry point of the MediBot application
@main
struct MediBotApp: App {

    var body: some Scene {
        // Defines the main app window and initial view
        WindowGroup {
            MainTabView()
        }
    }
}
