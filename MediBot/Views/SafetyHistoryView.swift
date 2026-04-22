//
//  SafetyHistoryView.swift
//  MediBot
//
//  Created by Zonish Sheikh 
//

import SwiftUI

// Displays previous safety checks with filtering and grouped history sections
struct SafetyHistoryView: View {
    @State private var checks: [SafetyCheckItem] = []
    @State private var isLoading = true
    @State private var errorMessage = ""
    @State private var selectedFilter: String = "All"

    private let filters = ["All", "High", "Caution", "Safe"]

    // Filters checks based on the selected severity
    private var filteredChecks: [SafetyCheckItem] {
        if selectedFilter == "All" {
            return checks
        }
        return checks.filter { $0.severity.lowercased() == selectedFilter.lowercased() }
    }

    // Groups filtered checks into dated history sections
    private var groupedChecks: [(String, [SafetyCheckItem])] {
        let grouped = Dictionary(grouping: filteredChecks) { item in
            sectionTitle(from: item.checked_at)
        }

        let orderedTitles = orderedSectionTitles(from: filteredChecks)

        return orderedTitles.map { title in
            (title, grouped[title] ?? [])
        }
    }

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    headerSection
                    filterBar

                    if isLoading {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                        .padding(.top, 40)

                    } else if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding(.horizontal)

                    } else if filteredChecks.isEmpty {
                        ContentUnavailableView(
                            "No Safety History",
                            systemImage: "clock.arrow.circlepath",
                            description: Text("Past interaction checks will appear here.")
                        )
                        .padding(.horizontal)

                    } else {
                        VStack(alignment: .leading, spacing: 20) {
                            ForEach(groupedChecks, id: \.0) { title, items in
                                VStack(alignment: .leading, spacing: 12) {
                                    Text(title)
                                        .font(.headline)

                                    VStack(spacing: 12) {
                                        ForEach(items) { check in
                                            historyCard(check)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
        }
        .navigationTitle("Safety History")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadAllChecks()
        }
        .refreshable {
            await loadAllChecks()
        }
    }

    // Header introducing the safety history screen
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("History Overview")
                .font(.title3)
                .fontWeight(.bold)

            Text("Browse past interaction checks and filter by severity.")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal)
    }

    // Horizontal filter bar for severity selection
    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(filters, id: \.self) { filter in
                    Button {
                        selectedFilter = filter
                    } label: {
                        Text(filter)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                selectedFilter == filter
                                ? Color.blue.opacity(0.14)
                                : Color(.systemGray6)
                            )
                            .foregroundColor(
                                selectedFilter == filter ? .blue : .primary
                            )
                            .cornerRadius(10)
                    }
                }
            }
            .padding(.horizontal)
        }
    }

    // Card displaying an individual safety history item
    private func historyCard(_ check: SafetyCheckItem) -> some View {
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

    // Fetches the full safety check history from the backend
    private func loadAllChecks() async {
        guard let url = URL(string: APIService.baseURL + "/safety-checks") else { return }

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
                errorMessage = "Failed to load safety history."
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

    // Generates a section title based on the check date
    private func sectionTitle(from isoString: String) -> String {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: isoString) else { return "Earlier" }

        let calendar = Calendar.current
        if calendar.isDateInToday(date) { return "Today" }
        if calendar.isDateInYesterday(date) { return "Yesterday" }

        let output = DateFormatter()
        output.dateFormat = "EEEE, d MMM"
        return output.string(from: date)
    }

    // Preserves the display order of grouped history section titles
    private func orderedSectionTitles(from items: [SafetyCheckItem]) -> [String] {
        let titles = items.map { sectionTitle(from: $0.checked_at) }
        var seen: [String] = []

        for title in titles where !seen.contains(title) {
            seen.append(title)
        }
        return seen
    }
}

#Preview {
    NavigationStack {
        SafetyHistoryView()
    }
}
