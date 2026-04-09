//
//  GenreModel.swift
//  moviehub-iOS
//
//  Created by Pavel Playerz0redd on 8.04.26.
//

import Foundation

struct GenreModel {
    let id: Int
    let name: String
}

extension GenreModel {
    init(from dto: GenreDTO.Genre) {
        self.id = dto.id
        self.name = dto.name
    }
}
