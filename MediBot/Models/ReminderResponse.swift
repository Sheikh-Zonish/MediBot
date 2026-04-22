//
//  ReminderResponse.swift
//  MediBot
//
//  Created by Zonish Sheikh
//

// Response model for reminder data returned from the backend
struct ReminderResponse: Codable {
    let medication: String?
    let time: String?
}
