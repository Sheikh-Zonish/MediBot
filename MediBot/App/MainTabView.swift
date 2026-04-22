//
//  MainTabView.swift
//  MediBot
//
//  Created by Zonish Sheikh
//

import SwiftUI

// Defines the available tabs in the application
enum AppTab: Hashable {
    case home
    case medications
    case insights
    case profile
}

// Main container view that manages tab navigation
struct MainTabView: View {

    // Stores the currently selected tab (default: home)
    @State private var selectedTab: AppTab = .home

    var body: some View {
        // TabView provides navigation between main sections
        TabView(selection: $selectedTab) {

            // Home screen tab
            HomeView(selectedTab: $selectedTab)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(AppTab.home)

            // Medications screen tab
            MedicationsView()
                .tabItem {
                    Image(systemName: "pills.fill")
                    Text("Medications")
                }
                .tag(AppTab.medications)

            // Insights screen tab
            InsightsView()
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("Insights")
                }
                .tag(AppTab.insights)

            // User profile screen tab
            ProfileView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
                .tag(AppTab.profile)
        }
    }
}

// SwiftUI preview for development
#Preview {
    MainTabView()
}
