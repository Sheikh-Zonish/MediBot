//
//  HomeView.swift
//  MediBot
//
//  Created by Zonish Sheikh 
//

import SwiftUI

struct HomeView: View {
    @Binding var selectedTab: AppTab

    @State private var medicationName: String = ""
    @State private var reminderTime: String = ""
    @State private var isLoading = true

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {

                // MARK: - Header
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

                // MARK: - Bot Illustration
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

                // MARK: - Description
                Text("""
Manage your medications safely with MediBot. Track your prescriptions, see potential interactions, and receive reminders tailored to your lifestyle.

Start managing your health smarter today.
""")
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

                // MARK: - Primary Button
                Button {
                    selectedTab = .medications
                } label: {
                    HStack {
                        Text("Check Interaction")
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

                // MARK: - Medication List
                Button {
                    selectedTab = .medications
                } label: {
                    HStack {
                        Image(systemName: "pills.fill")
                            .foregroundColor(.blue)

                        Text("Medication List")

                        Spacer()

                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                .padding(.horizontal)

                // MARK: - Health Tips / Upcoming Reminder
                VStack(alignment: .leading, spacing: 12) {
                    Text("Health Tips")
                        .font(.headline)

                    if !isLoading && !medicationName.isEmpty {
                        Button {
                            selectedTab = .insights
                        } label: {
                            HStack {
                                Image("Medibot_face")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 40, height: 40)

                                VStack(alignment: .leading) {
                                    Text("Upcoming Reminder")
                                        .fontWeight(.semibold)

                                    Text("Take \(medicationName) at \(reminderTime)")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }

                                Spacer()

                                Text("View All")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
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

    // MARK: - Backend
    private func loadUpcomingReminder() {
        Task {
            do {
                let response = try await APIService.fetchUpcomingReminder()
                medicationName = response.medication ?? ""
                reminderTime = response.time ?? ""
                isLoading = false
            } catch {
                print("Failed to load reminder:", error)
                isLoading = false
            }
        }
    }
}

#Preview {
    HomeView(selectedTab: .constant(.home))
}
