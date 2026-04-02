//
//  LoginResponseDTO.swift
//  moviehub-iOS
//
//  Created by Pavel Playerz0redd on 31.03.26.
//

import Foundation

struct AuthResponseDTO: Decodable {
    let accessToken: String
    let tokenType: String
}

struct ErrorAuthResponseDTO: Decodable {
    let detail: [Detail]
    
    struct Detail: Decodable {
        let msg: String
        let type: String
        let input: String
    }
}
