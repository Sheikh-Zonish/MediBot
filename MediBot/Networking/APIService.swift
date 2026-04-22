//
//  APIService.swift
//  MediBot
//
//  Created by Zonish Sheikh
//

import Foundation

// Handles all API communication between the app and backend
class APIService {

    // Base URL for backend server
    static let baseURL = "http://127.0.0.1:8000"

    // MARK: - Models

    struct ReminderResponse: Codable {
        let medication: String?
        let time: String?
    }

    struct DoseRequest: Codable {
        let medication: String
    }

    struct DoseLogResponse: Codable {
        let status: String
    }

    // Fetches the next upcoming medication reminder
    static func fetchUpcomingReminder() async throws -> ReminderResponse {
        guard let url = URL(string: baseURL + "/home/upcoming") else {
            throw URLError(.badURL)
        }

        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(ReminderResponse.self, from: data)
    }

    // Sends a request to log a medication dose
    static func logDose(medication: String) async throws -> DoseLogResponse {
        guard let url = URL(string: baseURL + "/log-dose") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = DoseRequest(medication: medication)
        request.httpBody = try JSONEncoder().encode(body)

        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(DoseLogResponse.self, from: data)
    }

    // Deletes the most recently logged dose
    static func deleteLastDose() async throws {
        guard let url = URL(string: baseURL + "/log-dose/latest") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"

        _ = try await URLSession.shared.data(for: request)
    }
}
