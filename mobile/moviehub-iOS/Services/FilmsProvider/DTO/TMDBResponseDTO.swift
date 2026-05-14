//
//  TMDBResponseDTO.swift
//  moviehub-iOS
//
//  Created by Pavel Playerz0redd on 8.04.26.
//

import Foundation

struct TMDBResponseDTO<Model: Decodable>: Decodable {
    let page: Int
    let results: Model
}
