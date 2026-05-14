//
//  StatsModel.swift
//  moviehub-iOS
//
//  Created by Pavel Playerz0redd on 25.04.26.
//

import Foundation

struct StatsModel {
    let liked: Int
    let disliked: Int
    let viewed: Int
}

extension StatsModel {
    init(from dto: StatsDTO) {
        self.liked = dto.liked
        self.disliked = dto.disliked
        self.viewed = dto.viewed
    }
    
    init() {
        self.liked = 0
        self.disliked = 0
        self.viewed = 0
    }
}
