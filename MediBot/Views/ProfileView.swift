//
//  ProfileView.swift
//  MediBot
//
//  Created by Zonish Sheikh
//

import SwiftUI

// Displays user profile information and navigation to app settings
struct ProfileView: View {
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // MARK: - Header
                    VStack(spacing: 10) {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .frame(width: 70, height: 70)
                            .foregroundColor(.blue.opacity(0.7))
                        
                        Text("MediBot User")
                            .font(.headline)
                        
                        Text("Medication safety and adherence support")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.04), radius: 6)
                    
                    // MARK: - Settings
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Settings")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        NavigationLink {
                            ReminderSettingsView()
                        } label: {
                            profileRow(
                                icon: "bell.fill",
                                color: .blue,
                                title: "Reminder Settings",
                                subtitle: "Manage reminder behaviour"
                            )
                        }
                        
                        NavigationLink {
                            PrivacyView()
                        } label: {
                            profileRow(
                                icon: "lock.fill",
                                color: .green,
                                title: "Privacy & Security",
                                subtitle: "How demo data is handled"
                            )
                        }
                    }
                    
                    // MARK: - About
                    VStack(alignment: .leading, spacing: 12) {
                        Text("About MediBot")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        NavigationLink {
                            AboutView()
                        } label: {
                            profileRow(
                                icon: "info.circle.fill",
                                color: .cyan,
                                title: "About MediBot",
                                subtitle: "App overview and purpose"
                            )
                        }
                        
                        profileRow(
                            icon: "gearshape.fill",
                            color: .gray,
                            title: "Version 1.0.0",
                            subtitle: "Current app build"
                        )
                    }
                }
                .padding()
            }
            .navigationTitle("Profile")
        }
    }
}

// Reusable row component for profile menu items
private func profileRow(
    icon: String,
    color: Color,
    title: String,
    subtitle: String
) -> some View {
    
    HStack(spacing: 12) {
        ZStack {
            Circle()
                .fill(color.opacity(0.15))
                .frame(width: 36, height: 36)
            
            Image(systemName: icon)
                .foregroundColor(color)
        }
        
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
            
            Text(subtitle)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        
        Spacer()
        
        Image(systemName: "chevron.right")
            .foregroundColor(.gray)
            .font(.caption)
    }
    .padding()
    .background(Color(.systemBackground))
    .cornerRadius(14)
    .shadow(color: .black.opacity(0.03), radius: 4)
}

#Preview {
    ProfileView()
}
