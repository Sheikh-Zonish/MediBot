//
//  AboutView.swift
//  MediBot
//
//  Created by Zonish Sheikh 
//

import SwiftUI

// Displays basic information about the MediBot application
struct AboutView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            Text("MediBot")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("MediBot helps users manage medications, check interactions, and improve adherence through reminders and insights.")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
        }
        .padding()
        .navigationTitle("About")
    }
}
