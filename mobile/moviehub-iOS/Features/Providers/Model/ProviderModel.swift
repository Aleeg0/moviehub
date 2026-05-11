//
//  ProviderModel.swift
//  moviehub-iOS
//
//  Created by Pavel Playerz0redd on 10.05.26.
//

import Foundation

struct ProviderModel: Hashable {
    let id: Int
    let logoPath: String
    let name: String
    let priority: Int
}

extension ProviderModel {
    init(from dto: ProviderDTO) {
        self.id = dto.id
        self.logoPath = "https://image.tmdb.org/t/p/original" + dto.logoPath
        self.name = dto.name
        self.priority = dto.priority
    }
}
