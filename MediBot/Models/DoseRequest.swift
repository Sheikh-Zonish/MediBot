//
//  DoseRequest.swift
//  MediBot
//
//  Created by Zonish Sheikh
//

// Request model for sending medication data to the API
struct DoseRequest: Codable {
    let medication: String
}
