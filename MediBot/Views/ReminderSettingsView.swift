//
//  ReminderSettingsView.swift
//  MediBot
//
//  Created by Zonish Sheikh on 12/04/2026.
//

import SwiftUI

// Allows users to enable reminders and configure their scheduled time
struct ReminderSettingsView: View {
    @AppStorage("remindersEnabled") private var remindersEnabled = true
    @AppStorage("reminderHour") private var reminderHour = 21
    @AppStorage("reminderMinute") private var reminderMinute = 0

    // Converts stored hour/minute values into a Date for use with DatePicker
    private var reminderBinding: Binding<Date> {
        Binding<Date>(
            get: {
                var components = DateComponents()
                components.hour = reminderHour
                components.minute = reminderMinute
                return Calendar.current.date(from: components) ?? Date()
            },
            set: { newValue in
                let components = Calendar.current.dateComponents([.hour, .minute], from: newValue)
                reminderHour = components.hour ?? 21
                reminderMinute = components.minute ?? 0
            }
        )
    }

    var body: some View {
        Form {
            Section {
                Toggle("Enable Reminders", isOn: $remindersEnabled)
            }

            if remindersEnabled {
                Section("Schedule") {
                    DatePicker(
                        "Reminder Time",
                        selection: reminderBinding,
                        displayedComponents: .hourAndMinute
                    )

                    Text("Reminders will appear daily at your selected time.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("Reminder Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        ReminderSettingsView()
    }
}
