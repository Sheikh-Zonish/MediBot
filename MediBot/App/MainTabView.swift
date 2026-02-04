//
//  ContentView.swift
//  MediBot
//
//  Created by Zonish Sheikh
//

import SwiftUI

enum AppTab: Hashable {
    case home
    case medications
    case insights
    case profile
}
import SwiftUI

struct MainTabView: View {

    @State private var selectedTab: AppTab = .home

    var body: some View {
        TabView(selection: $selectedTab) {

            HomeView(selectedTab: $selectedTab)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(AppTab.home)

            MedicationsView()
                .tabItem {
                    Image(systemName: "pills.fill")
                    Text("Medications")
                }
                .tag(AppTab.medications)

            InsightsView()
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("Insights")
                }
                .tag(AppTab.insights)

            ProfileView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
                .tag(AppTab.profile)
        }
    }
}

#Preview {
    MainTabView()
}
