//
//  RefreshTokensDTO.swift
//  moviehub-iOS
//
//  Created by Pavel Playerz0redd on 25.04.26.
//

import Foundation

struct RefreshTokensDTO: Codable {
    let refreshToken: String
}

struct NewTokensDTO: Codable {
    let accessToken: String
    let refreshToken: String
}
