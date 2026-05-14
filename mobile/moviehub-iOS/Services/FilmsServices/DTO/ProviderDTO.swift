//
//  File.swift
//  moviehub-iOS
//
//  Created by Pavel Playerz0redd on 10.05.26.
//

import Foundation

struct ProviderDTO: Decodable {
    let id: Int
    let name: String
    let logoPath: String
    let priority: Int
    
    enum CodingKeys: String, CodingKey {
        case id = "provider_id"
        case name = "provider_name"
        case logoPath = "logo_path"
        case priority = "display_priority"
    }
}


