//
//  InsightsView.swift
//  MediBot
//
//  Created by Zonish Sheikh
//

import SwiftUI

// Displays weekly adherence insights and medication safety activity
struct InsightsView: View {
    @State private var insights: InsightsResponse?
    @State private var isLoading = true
    @State private var errorMessage = ""

    @State private var animatedPercent: Double = 0
    @State private var barsAnimated = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        headerSection

                        if isLoading {
                            loadingSection
                        } else if let insights = insights {
                            adherenceCard(insights: insights)
                            quickStatsRow(insights: insights)
                            safetyLinksSection(insights: insights)
                        }

                        if !errorMessage.isEmpty {
                            Text(errorMessage)
                                .font(.footnote)
                                .foregroundColor(.red)
                                .padding(.horizontal)
                        }
                    }
                    .padding(.top, 8)
                    .padding(.bottom, 28)
                }
            }
            .navigationTitle("Insights")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await loadInsights()
            }
            .refreshable {
                await loadInsights()
            }
        }
    }

    // Header introducing the weekly insights section
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Weekly Overview")
                .font(.title3)
                .fontWeight(.bold)

            Text("Track your adherence and review recent safety activity.")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal)
    }

    // Loading state shown while insights are being fetched
    private var loadingSection: some View {
        HStack {
            Spacer()
            ProgressView()
            Spacer()
        }
        .padding(.top, 40)
    }

    // Main card showing adherence percentage and weekly chart
    private func adherenceCard(insights: InsightsResponse) -> some View {
        VStack(spacing: 22) {
            ZStack {
                Circle()
                    .stroke(Color.blue.opacity(0.10), lineWidth: 14)
                    .frame(width: 150, height: 150)

                Circle()
                    .trim(from: 0, to: animatedPercent / 100)
                    .stroke(
                        AngularGradient(
                            gradient: Gradient(colors: [
                                statusColor(for: insights.adherence_percent).opacity(0.6),
                                statusColor(for: insights.adherence_percent)
                            ]),
                            center: .center
                        ),
                        style: StrokeStyle(lineWidth: 14, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .frame(width: 150, height: 150)
                    .shadow(color: statusColor(for: insights.adherence_percent).opacity(0.18), radius: 6)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: animatedPercent)

                VStack(spacing: 3) {
                    Text("\(Int(animatedPercent))%")
                        .font(.system(size: 34, weight: .bold))

                    Text("\(insights.doses_taken)/\(insights.total_doses) doses")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)

                    Text("taken")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)

                    Text(statusText(for: insights.adherence_percent))
                        .font(.system(size: 10, weight: .semibold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(statusColor(for: insights.adherence_percent).opacity(0.12))
                        .foregroundColor(statusColor(for: insights.adherence_percent))
                        .cornerRadius(8)
                        .padding(.top, 2)
                }
                .offset(y: -2)
            }
            .padding(.top, 2)

            VStack(alignment: .leading, spacing: 14) {
                Text("Medication Adherence")
                    .font(.headline)

                weeklyBarChart(data: insights.weekly_doses)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(20)
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
            RoundedRectangle(cornerRadius: 22)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
        .cornerRadius(22)
        .shadow(color: .black.opacity(0.04), radius: 10, y: 3)
        .padding(.horizontal)
    }

    // Displays summary statistics for the current week
    private func quickStatsRow(insights: InsightsResponse) -> some View {
        HStack(alignment: .top, spacing: 12) {
            miniStatCard(
                title: "Taken",
                value: "\(insights.doses_taken)",
                icon: "checkmark.circle.fill",
                iconColor: .blue
            )

            miniStatCard(
                title: "Goal",
                value: "\(insights.total_doses)",
                icon: "target",
                iconColor: .purple
            )

            miniStatCard(
                title: "Checks",
                value: "\(insights.safety_checks_this_week)",
                icon: "checkmark.shield.fill",
                iconColor: .cyan
            )
        }
        .padding(.horizontal)
    }

    // Reusable card used for individual summary statistics
    private func miniStatCard(
        title: String,
        value: String,
        icon: String,
        iconColor: Color
    ) -> some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.12))
                    .frame(width: 36, height: 36)

                Image(systemName: icon)
                    .foregroundColor(iconColor)
                    .font(.system(size: 15, weight: .semibold))
            }

            Text(value)
                .font(.headline)
                .foregroundColor(.primary)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: 120)
        .padding(.vertical, 14)
        .background(
            LinearGradient(
                colors: [
                    Color(.systemBackground),
                    Color(.systemGray6).opacity(0.35)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.025), radius: 4, y: 1)
    }

    // Navigation links to safety-related insight screens
    private func safetyLinksSection(insights: InsightsResponse) -> some View {
        VStack(spacing: 12) {
            NavigationLink {
                MedicationSafetyView()
            } label: {
                insightRowCard(
                    icon: "checkmark.shield.fill",
                    iconColor: .blue,
                    title: "Safety Checks This Week",
                    subtitle: "\(insights.safety_checks_this_week) Checks Triggered\nIn the Last 7 Days"
                )
            }
            .buttonStyle(.plain)

            NavigationLink {
                SafetyHistoryView()
            } label: {
                insightRowCard(
                    icon: "clock.arrow.circlepath",
                    iconColor: .cyan,
                    title: "Safety History",
                    subtitle: "Review previous interaction checks"
                )
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal)
    }

    // Builds the weekly adherence bar chart
    private func weeklyBarChart(data: [WeeklyDose]) -> some View {
        let maxValue = max(data.map { $0.value }.max() ?? 1, 1)
        let todayLabel = DateFormatter.shortWeekday.string(from: Date())

        return VStack(alignment: .leading, spacing: 10) {
            ZStack(alignment: .bottomLeading) {
                VStack(spacing: 0) {
                    ForEach(0..<4, id: \.self) { _ in
                        Divider()
                            .background(Color.gray.opacity(0.15))
                        Spacer()
                    }
                }
                .frame(height: 100)

                HStack(alignment: .bottom, spacing: 12) {
                    ForEach(Array(data.enumerated()), id: \.element.id) { index, item in
                        let isToday = item.day == todayLabel
                        let color = barColor(for: item.value, maxValue: maxValue, isToday: isToday)
                        let barHeight = barsAnimated
                            ? max(CGFloat(item.value) / CGFloat(maxValue) * 84, 14)
                            : 14

                        VStack(spacing: 8) {
                            ZStack(alignment: .top) {
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(isToday ? Color.teal.opacity(0.8) : Color.clear)
                                    .frame(width: 30, height: 104)

                                RoundedRectangle(cornerRadius: 5)
                                    .fill(color)
                                    .frame(width: 22, height: barHeight)
                                    .padding(.top, 10)
                                    .offset(y: 94 - barHeight)
                                    .animation(
                                        .easeOut(duration: 0.55).delay(Double(index) * 0.05),
                                        value: barsAnimated
                                    )
                            }
                            .frame(height: 104)

                            Text(item.day)
                                .font(.caption2)
                                .fontWeight(isToday ? .semibold : .regular)
                                .foregroundColor(isToday ? .teal : .secondary)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 4)
    }

    // Reusable row card for insight navigation items
    private func insightRowCard(
        icon: String,
        iconColor: Color,
        title: String,
        subtitle: String
    ) -> some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.12))
                    .frame(width: 38, height: 38)

                Image(systemName: icon)
                    .foregroundColor(iconColor)
                    .font(.system(size: 16, weight: .semibold))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
                .font(.caption)
                .padding(.top, 4)
        }
        .padding(16)
        .frame(minHeight: 88)
        .background(
            LinearGradient(
                colors: [
                    Color(.systemBackground),
                    Color(.systemGray6).opacity(0.25)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.02), radius: 4, y: 1)
    }

    // Returns a text label based on adherence percentage
    private func statusText(for percent: Int) -> String {
        switch percent {
        case 80...100:
            return "On Track"
        case 50..<80:
            return "Needs Attention"
        default:
            return "Low Adherence"
        }
    }

    // Returns a colour representing adherence level
    private func statusColor(for percent: Int) -> Color {
        let p = Double(percent) / 100.0
        let red = max(0, 1 - p * 1.2)
        let green = min(1, p * 1.2)
        return Color(red: red, green: green, blue: 0)
    }

    // Determines the visual style of each chart bar
    private func barColor(for value: Int, maxValue: Int, isToday: Bool) -> Color {
        guard value > 0 else {
            return Color.gray.opacity(0.28)
        }

        let intensity = Double(value) / Double(maxValue)
        let base = Color(red: 0.25, green: 0.55, blue: 0.60)

        if isToday {
            return base.opacity(0.80)
        } else {
            return base.opacity(0.55 + (intensity * 0.25))
        }
    }

    // Fetches insights data from the backend and updates the UI
    private func loadInsights() async {
        guard let url = URL(string: APIService.baseURL + "/insights") else { return }

        do {
            await MainActor.run {
                isLoading = true
                errorMessage = ""
                animatedPercent = 0
                barsAnimated = false
            }

            let (data, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode(InsightsResponse.self, from: data)

            await MainActor.run {
                insights = decoded
                isLoading = false
            }

            await MainActor.run {
                withAnimation(.easeInOut(duration: 0.9)) {
                    animatedPercent = Double(decoded.adherence_percent)
                }
                barsAnimated = true
            }
        } catch {
            await MainActor.run {
                errorMessage = "Failed to load insights"
                isLoading = false
                print(error)
            }
        }
    }
}

// Shared formatter used to match the current weekday with chart labels
private extension DateFormatter {
    static let shortWeekday: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter
    }()
}

#Preview {
    InsightsView()
}
