//
//  GenresDTO.swift
//  moviehub-iOS
//
//  Created by Pavel Playerz0redd on 8.04.26.
//

import Foundation


struct GenreDTO: Decodable {
    let genres: [Genre]
    
    struct Genre: Decodable {
        let id: Int
        let name: String
    }
    
}
