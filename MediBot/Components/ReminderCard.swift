//
//  ReminderCard.swift
//  MediBot
//
//  Created by Zonish Sheikh
//

import SwiftUI

struct ReminderCard: View {
    let medication: String
    let time: String

    var body: some View {
        HStack(spacing: 12) {

            Image(systemName: "bell.fill")
                .foregroundColor(.blue)
                .font(.title2)

            VStack(alignment: .leading, spacing: 4) {
                Text("Upcoming Reminder")
                    .font(.headline)

                Text("Take \(medication) at \(time)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()

            Text("View All")
                .font(.caption)
                .foregroundColor(.blue)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(14)
    }
}
