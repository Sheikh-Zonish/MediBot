//
//  InteractionCheckView.swift
//  MediBot
//
//  Created by Zonish Sheikh
//

import SwiftUI

// Response model returned after checking a medication interaction
struct InteractionResponse: Codable {
    let severity: String
    let message: String
}

// Allows the user to check medication interactions with lifestyle factors
struct InteractionCheckView: View {
    let selectedMedication: Medication
    @Environment(\.dismiss) private var dismiss

    @State private var caffeine = false
    @State private var alcohol = false
    @State private var supplements = false

    @State private var interactionResult: InteractionResponse?
    @State private var errorMessage = ""
    @State private var isChecking = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text("Select Medication & Lifestyle")
                    .font(.title2)
                    .fontWeight(.bold)

                selectedMedicationCard
                lifestyleCard
                checkInteractionButton

                if let result = interactionResult {
                    resultCard(result)
                }

                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundColor(.red)
                }
            }
            .padding()
        }
        .navigationTitle("Medications")
        .navigationBarTitleDisplayMode(.inline)
    }

    // Displays the currently selected medication
    private var selectedMedicationCard: some View {
        Button {
            dismiss()
        } label: {
            HStack {
                Text(selectedMedication.name)
                    .foregroundColor(.primary)

                Spacer()

                Text("Change")
                    .font(.subheadline)
                    .foregroundColor(.blue)

                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }

    // Displays lifestyle factors used in the interaction check
    private var lifestyleCard: some View {
        VStack(spacing: 14) {
            LifestyleToggleRow(
                title: "Caffeine",
                icon: "leaf.fill",
                iconColor: .green,
                isOn: $caffeine
            )

            LifestyleToggleRow(
                title: "Alcohol",
                icon: "wineglass.fill",
                iconColor: .orange,
                isOn: $alcohol
            )

            LifestyleToggleRow(
                title: "Supplements",
                icon: "pills.fill",
                iconColor: .yellow,
                isOn: $supplements
            )
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }

    // Button that sends the interaction check request
    private var checkInteractionButton: some View {
        Button {
            checkInteraction()
        } label: {
            HStack {
                Spacer()

                if isChecking {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("Check Interaction")
                        .fontWeight(.semibold)

                    Image(systemName: "chevron.right")
                }

                Spacer()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .disabled(isChecking)
        .opacity(isChecking ? 0.8 : 1.0)
    }

    // Displays the interaction result returned from the backend
    private func resultCard(_ result: InteractionResponse) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 12) {
                ZStack {
                    Circle()
                        .fill(cardAccentColor(for: result.severity).opacity(0.15))
                        .frame(width: 34, height: 34)

                    Image(systemName: cardIconName(for: result.severity))
                        .foregroundColor(cardAccentColor(for: result.severity))
                        .font(.system(size: 18, weight: .semibold))
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("\(result.severity): \(selectedMedication.name)")
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text(result.message)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            Button("Learn More") {
            }
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundColor(.blue)
            .frame(maxWidth: .infinity)
        }
        .padding()
        .background(cardBackgroundColor(for: result.severity))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(cardBorderColor(for: result.severity), lineWidth: 1)
        )
        .cornerRadius(16)
    }

    // Returns an icon based on interaction severity
    private func cardIconName(for severity: String) -> String {
        switch severity.lowercased() {
        case "high":
            return "exclamationmark.triangle.fill"
        case "caution":
            return "shield.lefthalf.filled"
        default:
            return "checkmark.shield.fill"
        }
    }

    // Returns an accent colour based on interaction severity
    private func cardAccentColor(for severity: String) -> Color {
        switch severity.lowercased() {
        case "high":
            return .red
        case "caution":
            return .yellow
        default:
            return .green
        }
    }

    // Returns a background colour for the result card
    private func cardBackgroundColor(for severity: String) -> Color {
        switch severity.lowercased() {
        case "high":
            return Color.red.opacity(0.06)
        case "caution":
            return Color.yellow.opacity(0.08)
        default:
            return Color(.systemBackground)
        }
    }

    // Returns a border colour for the result card
    private func cardBorderColor(for severity: String) -> Color {
        switch severity.lowercased() {
        case "high":
            return Color.red.opacity(0.25)
        case "caution":
            return Color.yellow.opacity(0.35)
        default:
            return Color(.systemGray4)
        }
    }

    // Sends the selected medication and lifestyle data to the backend
    private func checkInteraction() {
        guard let url = URL(string: APIService.baseURL + "/check-interaction") else { return }

        let body: [String: Any] = [
            "medication": selectedMedication.name,
            "alcohol": alcohol,
            "caffeine": caffeine,
            "supplements": supplements
        ]

        Task {
            do {
                isChecking = true
                errorMessage = ""

                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.httpBody = try JSONSerialization.data(withJSONObject: body)

                let (data, _) = try await URLSession.shared.data(for: request)
                interactionResult = try JSONDecoder().decode(InteractionResponse.self, from: data)

                isChecking = false
            } catch {
                errorMessage = "Failed to check interaction"
                isChecking = false
                print(error)
            }
        }
    }
}

// Reusable row for each lifestyle toggle option
struct LifestyleToggleRow: View {
    let title: String
    let icon: String
    let iconColor: Color
    @Binding var isOn: Bool

    var body: some View {
        HStack {
            Label {
                Text(title)
                    .foregroundColor(.primary)
            } icon: {
                Image(systemName: icon)
                    .foregroundColor(iconColor)
            }

            Spacer()

            Toggle("", isOn: $isOn)
                .labelsHidden()
        }
    }
}

#Preview {
    NavigationStack {
        InteractionCheckView(
            selectedMedication: Medication(
                id: 1,
                name: "Atorvastatin",
                generic_info: "Generic (Lipitor)",
                condition: "Cholesterol",
                color_hex: "#F4C542",
                is_suggested: true
            )
        )
    }
}
