//
//  MedicationSafetyView.swift
//  MediBot
//
//  Created by Zonish Sheikh on 11/04/2026.
//

import SwiftUI

// Model representing a safety check returned from the backend
struct SafetyCheckItem: Codable, Identifiable {
    let id: Int
    let medication_name: String
    let severity: String
    let message: String
    let checked_at: String
}

// Displays weekly medication safety checks and severity trends
struct MedicationSafetyView: View {
    @State private var checks: [SafetyCheckItem] = []
    @State private var isLoading = true
    @State private var errorMessage = ""

    // Number of checks marked as high severity
    private var highCount: Int {
        checks.filter { $0.severity.lowercased() == "high" }.count
    }

    // Number of checks marked as caution
    private var cautionCount: Int {
        checks.filter { $0.severity.lowercased() == "caution" }.count
    }

    // Number of checks marked as safe
    private var safeCount: Int {
        checks.filter { $0.severity.lowercased() == "safe" }.count
    }

    // Returns the most recent safety checks for display
    private var recentChecks: [SafetyCheckItem] {
        Array(checks.prefix(3))
    }

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    headerSection

                    if isLoading {
                        loadingSection
                    } else if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding(.horizontal)
                    } else {
                        summaryCard
                        severityBreakdown
                        recentChecksSection
                    }
                }
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
        }
        .navigationTitle("Safety Checks This Week")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadWeeklyChecks()
        }
        .refreshable {
            await loadWeeklyChecks()
        }
    }

    // Header introducing the weekly safety overview
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Weekly Safety Overview")
                .font(.title3)
                .fontWeight(.bold)

            Text("Review recent interaction checks and severity trends.")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal)
    }

    // Loading state shown while safety data is being fetched
    private var loadingSection: some View {
        HStack {
            Spacer()
            ProgressView()
            Spacer()
        }
        .padding(.top, 40)
    }

    // Summary card showing the number of checks recorded this week
    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Checks Recorded")
                .font(.headline)

            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.12))
                        .frame(width: 64, height: 64)

                    Image(systemName: "checkmark.shield.fill")
                        .foregroundColor(.blue)
                        .font(.system(size: 26, weight: .semibold))
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("\(checks.count)")
                        .font(.system(size: 32, weight: .bold))

                    Text("Interaction checks in the last 7 days")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()
            }
        }
        .padding()
        .background(
            LinearGradient(
                colors: [
                    Color(.systemBackground),
                    Color.blue.opacity(0.02)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
        .padding(.horizontal)
    }

    // Displays a breakdown of safety checks by severity
    private var severityBreakdown: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Severity Breakdown")
                .font(.headline)
                .padding(.horizontal)

            HStack(spacing: 12) {
                severityMiniCard(
                    title: "High",
                    count: highCount,
                    color: .red,
                    icon: "exclamationmark.triangle.fill"
                )

                severityMiniCard(
                    title: "Caution",
                    count: cautionCount,
                    color: .orange,
                    icon: "shield.lefthalf.filled"
                )

                severityMiniCard(
                    title: "Safe",
                    count: safeCount,
                    color: .green,
                    icon: "checkmark.shield.fill"
                )
            }
            .padding(.horizontal)
        }
    }

    // Displays the most recent safety checks
    private var recentChecksSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Checks")
                .font(.headline)
                .padding(.horizontal)

            if recentChecks.isEmpty {
                ContentUnavailableView(
                    "No Checks Yet",
                    systemImage: "clock.badge.xmark",
                    description: Text("Interaction checks from this week will appear here.")
                )
                .padding(.horizontal)
            } else {
                VStack(spacing: 12) {
                    ForEach(recentChecks) { check in
                        safetyCard(check)
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    // Reusable card for displaying severity counts
    private func severityMiniCard(
        title: String,
        count: Int,
        color: Color,
        icon: String
    ) -> some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.12))
                    .frame(width: 40, height: 40)

                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.system(size: 15, weight: .semibold))
            }

            Text("\(count)")
                .font(.title3)
                .fontWeight(.bold)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color(.systemBackground))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.02), radius: 4, y: 1)
    }

    // Card displaying an individual safety check
    private func safetyCard(_ check: SafetyCheckItem) -> some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(severityColor(check.severity).opacity(0.14))
                    .frame(width: 42, height: 42)

                Image(systemName: severityIcon(check.severity))
                    .foregroundColor(severityColor(check.severity))
                    .font(.system(size: 16, weight: .semibold))
            }

            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .top) {
                    Text(check.medication_name)
                        .font(.headline)

                    Spacer()

                    Text(check.severity)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(severityColor(check.severity).opacity(0.12))
                        .foregroundColor(severityColor(check.severity))
                        .cornerRadius(8)
                }

                Text(check.message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                Text(formattedDate(check.checked_at))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.02), radius: 4, y: 1)
    }

    // Fetches weekly safety check data from the backend
    private func loadWeeklyChecks() async {
        guard let url = URL(string: APIService.baseURL + "/safety-checks/weekly") else { return }

        do {
            await MainActor.run {
                isLoading = true
                errorMessage = ""
            }

            let (data, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode([SafetyCheckItem].self, from: data)

            await MainActor.run {
                checks = decoded
                isLoading = false
            }
        } catch {
            await MainActor.run {
                errorMessage = "Failed to load weekly safety checks."
                isLoading = false
            }
        }
    }

    // Returns a colour based on severity level
    private func severityColor(_ severity: String) -> Color {
        switch severity.lowercased() {
        case "high":
            return .red
        case "caution":
            return .orange
        default:
            return .green
        }
    }

    // Returns an icon based on severity level
    private func severityIcon(_ severity: String) -> String {
        switch severity.lowercased() {
        case "high":
            return "exclamationmark.triangle.fill"
        case "caution":
            return "shield.lefthalf.filled"
        default:
            return "checkmark.shield.fill"
        }
    }

    // Converts an ISO date string into a readable format
    private func formattedDate(_ isoString: String) -> String {
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: isoString) {
            let output = DateFormatter()
            output.dateStyle = .medium
            output.timeStyle = .short
            return output.string(from: date)
        }
        return isoString
    }
}

#Preview {
    NavigationStack {
        MedicationSafetyView()
    }
}
