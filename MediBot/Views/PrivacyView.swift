//
//  PrivacyView.swift
//  MediBot
//
//  Created by Zonish Sheikh on 12/04/2026.
//

import SwiftUI

// Displays basic privacy and data usage information
struct PrivacyView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Privacy & Security")
                .font(.title3)
                .fontWeight(.bold)
            
            Text("This app does not store personal user data. All information is used for demonstration purposes only.")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
        }
        .padding()
        .navigationTitle("Privacy")
    }
}
