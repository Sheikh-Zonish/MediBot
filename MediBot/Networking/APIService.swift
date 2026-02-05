//
//  APIService.swift
//  MediBot
//
//  Created by Zonish Sheikh
//

import Foundation
class APIService {

    static let baseURL = "http://127.0.0.1:8000"

    static func fetchUpcomingReminder() async throws -> ReminderResponse {
        let url = URL(string: baseURL + "/home/upcoming")!
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(ReminderResponse.self, from: data)
    }

    static func logDose(medication: String) async throws {
        let url = URL(string: baseURL + "/log-dose")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = DoseRequest(medication: medication)
        request.httpBody = try JSONEncoder().encode(body)

        _ = try await URLSession.shared.data(for: request)
    }
}
