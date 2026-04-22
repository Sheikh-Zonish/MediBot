//
//  ReminderCard.swift
//  MediBot
//
//  Created by Zonish Sheikh
//

import SwiftUI

// Reusable card view to display an upcoming medication reminder
struct ReminderCard: View {

    // Medication name and scheduled time for the reminder
    let medication: String
    let time: String

    var body: some View {
        // Horizontal layout for icon, text, and action
        HStack(spacing: 12) {

            Image(systemName: "bell.fill")
                .foregroundColor(.blue)
                .font(.title2)

            // Displays reminder title and details
            VStack(alignment: .leading, spacing: 4) {
                Text("Upcoming Reminder")
                    .font(.headline)

                Text("Take \(medication) at \(time)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            Spacer()

            // Placeholder action text (e.g., navigate to full reminders list)
            Text("View All")
                .font(.caption)
                .foregroundColor(.blue)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(14)
    }
}
