//
//  InsightsModel.swift
//  MediBot
//
//  Created by Zonish Sheikh
//

import Foundation

// Response model for adherence insights returned from the backend
struct InsightsResponse: Codable {
    let adherence_percent: Int
    let doses_taken: Int
    let total_doses: Int
    let weekly_doses: [WeeklyDose]
    let safety_checks_this_week: Int
}

// Represents daily dose data used for weekly charts
struct WeeklyDose: Codable, Identifiable {
    let id = UUID()
    let day: String
    let value: Int

    enum CodingKeys: String, CodingKey {
        case day
        case value
    }
}
