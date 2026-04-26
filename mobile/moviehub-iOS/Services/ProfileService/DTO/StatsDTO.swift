//
//  StatsDTO.swift
//  moviehub-iOS
//
//  Created by Pavel Playerz0redd on 25.04.26.
//

import Foundation

struct StatsDTO: Decodable {
    let liked: Int
    let disliked: Int
    let viewed: Int
}
