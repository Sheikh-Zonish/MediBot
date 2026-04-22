//
//  MedicationsView.swift
//  MediBot
//
//  Created by Zonish Sheikh
//

import SwiftUI

// Model representing a medication returned from the backend
struct Medication: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
    let generic_info: String
    let condition: String
    let color_hex: String
    let is_suggested: Bool
}

// Displays the medication list with search, filtering, and suggestions
struct MedicationsView: View {
    @State private var medications: [Medication] = []
    @State private var searchText = ""
    @State private var selectedCondition = "All"
    @State private var errorMessage = ""
    @State private var isLoading = true

    // Suggested medications highlighted for quick access
    private var suggestedMedications: [Medication] {
        medications.filter { $0.is_suggested }
    }

    // Available condition filters built from the medication list
    private var allConditions: [String] {
        let conditions = Set(medications.map { $0.condition })
        return ["All"] + conditions.sorted()
    }

    // Filters medications by search text and selected condition
    private var filteredMedications: [Medication] {
        medications.filter { med in
            let matchesSearch =
                searchText.isEmpty ||
                med.name.localizedCaseInsensitiveContains(searchText)

            let matchesCondition =
                selectedCondition == "All" ||
                med.condition == selectedCondition

            return matchesSearch && matchesCondition
        }
    }

    // Groups medications alphabetically for sectioned display
    private var groupedMedications: [String: [Medication]] {
        Dictionary(grouping: filteredMedications) { med in
            String(med.name.prefix(1)).uppercased()
        }
    }

    // Sorted section titles used in the alphabetical list
    private var sortedSectionKeys: [String] {
        groupedMedications.keys.sorted()
    }

    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                ZStack(alignment: .trailing) {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 18) {
                            searchBar
                            infoCard

                            if searchText.isEmpty {
                                suggestionsSection
                            }

                            conditionsSection
                            allMedicationsSection
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        .padding(.bottom, 24)
                    }

                    if !sortedSectionKeys.isEmpty {
                        alphabetIndex(proxy: proxy)
                            .padding(.trailing, 4)
                            .frame(maxHeight: .infinity, alignment: .center)
                    }
                }
            }
            .navigationTitle("Select Medication")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                loadMedications()
            }
        }
    }

    // Search field for finding medications by name
    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)

            TextField("Search Medications...", text: $searchText)

            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }

    // Informational note about the prototype dataset
    private var infoCard: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "info.circle.fill")
                .foregroundColor(.blue)

            Text("Prototype data includes common medications for demo purpose only.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
        }
        .padding()
        .background(Color.blue.opacity(0.08))
        .cornerRadius(12)
    }

    // Displays suggested medications when no search is active
    private var suggestionsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Suggestions")
                .font(.headline)

            VStack(spacing: 0) {
                ForEach(Array(suggestedMedications.enumerated()), id: \.element.id) { index, med in
                    NavigationLink {
                        InteractionCheckView(selectedMedication: med)
                    } label: {
                        MedicationRow(medication: med)
                    }

                    if index < suggestedMedications.count - 1 {
                        Divider()
                            .padding(.leading, 44)
                    }
                }
            }
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(.systemGray5), lineWidth: 1)
            )
        }
    }

    // Horizontal filter chips for browsing by condition
    private var conditionsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Browse by Condition")
                .font(.headline)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(allConditions, id: \.self) { condition in
                        Button {
                            selectedCondition = condition
                        } label: {
                            Text(condition)
                                .font(.caption)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(
                                    selectedCondition == condition
                                    ? Color.blue.opacity(0.15)
                                    : Color(.systemGray6)
                                )
                                .foregroundColor(
                                    selectedCondition == condition ? .blue : .primary
                                )
                                .cornerRadius(10)
                        }
                    }
                }
            }
        }
    }

    // Displays the full medication list grouped alphabetically
    private var allMedicationsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundColor(.red)
            }

            if isLoading {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                .padding(.vertical, 24)
            } else if filteredMedications.isEmpty {
                VStack(spacing: 8) {
                    Text("No medications found")
                        .font(.headline)

                    Text("Try searching with a different name.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
            } else {
                ForEach(sortedSectionKeys, id: \.self) { key in
                    VStack(alignment: .leading, spacing: 10) {
                        Text(key)
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .id(key)

                        VStack(spacing: 0) {
                            ForEach(Array((groupedMedications[key] ?? []).enumerated()), id: \.element.id) { index, med in
                                NavigationLink {
                                    InteractionCheckView(selectedMedication: med)
                                } label: {
                                    MedicationRow(medication: med)
                                }

                                if index < (groupedMedications[key]?.count ?? 0) - 1 {
                                    Divider()
                                        .padding(.leading, 44)
                                }
                            }
                        }
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(.systemGray5), lineWidth: 1)
                        )
                    }
                }
            }
        }
    }

    // Alphabet index for quick navigation between medication sections
    private func alphabetIndex(proxy: ScrollViewProxy) -> some View {
        let letters = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ").map { String($0) }

        return VStack(spacing: 4) {
            ForEach(letters, id: \.self) { letter in
                Button {
                    if sortedSectionKeys.contains(letter) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            proxy.scrollTo(letter, anchor: .top)
                        }
                    }
                } label: {
                    Text(letter)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(sortedSectionKeys.contains(letter) ? .blue : .gray.opacity(0.35))
                        .frame(width: 18, height: 12)
                }
                .disabled(!sortedSectionKeys.contains(letter))
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 6)
        .background(Color(.systemBackground).opacity(0.94))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.08), radius: 3)
    }

    // Fetches the medication list from the backend
    private func loadMedications() {
        guard let url = URL(string: APIService.baseURL + "/medications") else { return }

        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                medications = try JSONDecoder().decode([Medication].self, from: data)
                errorMessage = ""
                isLoading = false
            } catch {
                errorMessage = "Failed to load medications"
                isLoading = false
                print(error)
            }
        }
    }
}

// Reusable row for displaying a medication item
struct MedicationRow: View {
    let medication: Medication

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color(hex: medication.color_hex))
                .frame(width: 18, height: 18)

            VStack(alignment: .leading, spacing: 2) {
                Text(medication.name)
                    .foregroundColor(.primary)

                Text(medication.generic_info)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
                .font(.caption)
        }
        .padding()
    }
}

// Converts hex colour strings into SwiftUI Color values
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let r, g, b: UInt64
        switch hex.count {
        case 6:
            r = (int >> 16) & 0xFF
            g = (int >> 8) & 0xFF
            b = int & 0xFF
        default:
            r = 0
            g = 0
            b = 0
        }

        self.init(
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255
        )
    }
}

#Preview {
    MedicationsView()
}
