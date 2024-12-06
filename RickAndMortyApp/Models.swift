//
//  Models.swift
//  RickAndMortyApp
//
//  Created by Камиль Байдиев on 27.07.2024.
//

import Foundation

struct Episode: Codable {
    let id: Int
    let name: String
    let air_date: String
    let episode: String
    let characters: [String]
    let url: String
    let created: String
}

struct EpisodesResponse: Codable {
    let results: [Episode]
}

struct Character: Codable {
    let image: String?
    let name: String?
    let gender: String?
    let status: String?
    let species: String?
    let origin: Location?
    let location: Location?
    let type: String?
    
}

struct RMCharacter: Codable{
    let id: Int
    let name: String
    let species: String
    let type: String
    let image: String
    let episode: [String]
    let url: String
    let created: String
    let gender: String
}

struct Location: Codable {
    let name: String?
}
