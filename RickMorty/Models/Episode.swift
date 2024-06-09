//
//  Episode.swift
//  RickMorty
//
//  Created by Adam Kopeć on 08/06/2024.
//

import Foundation

struct Episode: Codable, Identifiable {
    let id: Int
    let name: String
    let air_date: String
    let episode: String
    let characters: [URL]
}
