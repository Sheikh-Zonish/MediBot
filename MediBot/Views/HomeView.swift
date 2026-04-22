//
//  HomeView.swift
//  MediBot
//
//  Created by Zonish Sheikh
//

import SwiftUI

// Main home screen showing app navigation, reminders, and dose tracking
struct HomeView: View {
    @Binding var selectedTab: AppTab

    @AppStorage("remindersEnabled") private var remindersEnabled = true
    @AppStorage("reminderHour") private var reminderHour = 21
    @AppStorage("reminderMinute") private var reminderMinute = 0

    @State private var medicationName: String = ""
    @State private var reminderTime: String = ""
    @State private var isLoading = true
    @State private var isLoggingDose = false
    @State private var doseLoggedMessage = ""
    @State private var hasLoggedDoseToday = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                
                // Header section with title and navigation to profile
                HStack {
                    Text("Welcome to MediBot")
                        .font(.title2)
                        .fontWeight(.semibold)

                    Spacer()

                    Button {
                        selectedTab = .profile
                    } label: {
                        Image(systemName: "bell")
                            .foregroundColor(.gray)
                            .bold()
                            .padding(8)
                    }
                }
                .padding(.horizontal)

                // App illustration
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.blue.opacity(0.15),
                                    Color.blue.opacity(0.05)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 200, height: 200)

                    Image("Medibot_face")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200)
                }
                .shadow(color: .blue.opacity(0.15), radius: 10)

                // Introductory text explaining the app purpose
                Text("""
Manage your medications safely with MediBot. Review your prescriptions, check lifestyle interactions, and stay on track with timely reminders.

Start managing your health with more confidence.
""")
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

                // Button to navigate directly to medication interaction checking
                Button {
                    selectedTab = .medications
                } label: {
                    HStack {
                        Text("Check Medication Interaction")
                            .fontWeight(.semibold)
                        Image(systemName: "chevron.right")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .padding(.horizontal)

                // Button to open the medications section
                Button {
                    selectedTab = .medications
                } label: {
                    HStack {
                        Image(systemName: "pills.fill")
                            .foregroundColor(.blue)

                        Text("Browse Medications")

                        Spacer()

                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                .padding(.horizontal)

                // Reminder section showing upcoming medication and dose actions
                VStack(alignment: .leading, spacing: 12) {
                    Text("Reminders")
                        .font(.headline)

                    if isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, 12)

                    } else if !medicationName.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(alignment: .center, spacing: 12) {
                                Image("Medibot_face")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 40, height: 40)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Upcoming Reminder")
                                        .fontWeight(.semibold)

                                    Text("Take \(medicationName) at \(formattedReminderPreference())")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }

                                Spacer()

                                Button {
                                    if hasLoggedDoseToday {
                                        undoDose()
                                    } else {
                                        markDoseAsTaken()
                                    }
                                } label: {
                                    if isLoggingDose {
                                        ProgressView()
                                            .tint(.blue)
                                            .frame(width: 70)

                                    } else if hasLoggedDoseToday {
                                        Text("Undo")
                                            .font(.caption)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.red)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 8)
                                            .background(Color.red.opacity(0.1))
                                            .cornerRadius(10)

                                    } else {
                                        Text("Taken")
                                            .font(.caption)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.blue)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 8)
                                            .background(Color.blue.opacity(0.1))
                                            .cornerRadius(10)
                                    }
                                }
                                .disabled(isLoggingDose)
                                .opacity(isLoggingDose ? 0.75 : 1.0)
                            }

                            if !doseLoggedMessage.isEmpty {
                                Text(doseLoggedMessage)
                                    .font(.caption)
                                    .foregroundColor(hasLoggedDoseToday ? .green : .red)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)

                    } else {
                        Text("No reminder set yet.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.top)
        }
        .onAppear {
            loadUpcomingReminder()
        }
    }

    // Loads the next scheduled reminder from the backend
    private func loadUpcomingReminder() {
        Task {
            do {
                let response = try await APIService.fetchUpcomingReminder()
                medicationName = response.medication ?? ""
                reminderTime = response.time ?? ""
                isLoading = false
                doseLoggedMessage = ""
            } catch {
                print("Failed to load reminder:", error)
                isLoading = false
            }
        }
    }

    // Marks the current medication dose as taken
    private func markDoseAsTaken() {
        guard !medicationName.isEmpty else { return }
        guard !hasLoggedDoseToday else { return }

        Task {
            do {
                isLoggingDose = true
                doseLoggedMessage = ""

                let response = try await APIService.logDose(medication: medicationName)

                if response.status == "logged" {
                    hasLoggedDoseToday = true
                    doseLoggedMessage = "Dose logged successfully."
                } else if response.status == "already_logged" {
                    hasLoggedDoseToday = true
                    doseLoggedMessage = "Today's dose has already been logged."
                } else {
                    doseLoggedMessage = "Unexpected response."
                }

                isLoggingDose = false
            } catch {
                print("Failed to log dose:", error)
                doseLoggedMessage = "Failed to log dose."
                isLoggingDose = false
            }
        }
    }

    // Removes the most recently logged dose
    private func undoDose() {
        Task {
            do {
                isLoggingDose = true
                doseLoggedMessage = ""

                try await APIService.deleteLastDose()

                hasLoggedDoseToday = false
                doseLoggedMessage = "Dose removed successfully."
                isLoggingDose = false
            } catch {
                print("Failed to delete dose:", error)
                doseLoggedMessage = "Failed to undo dose."
                isLoggingDose = false
            }
        }
    }

    // Formats the saved reminder time for display
    private func formattedReminderPreference() -> String {
        var components = DateComponents()
        components.hour = reminderHour
        components.minute = reminderMinute

        let date = Calendar.current.date(from: components) ?? Date()

        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none

        return formatter.string(from: date)
    }
}

#Preview {
    HomeView(selectedTab: .constant(.home))
}
