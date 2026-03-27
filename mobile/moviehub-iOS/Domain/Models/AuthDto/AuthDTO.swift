//
//  AuthDTO.swift
//  moviehub-iOS
//
//  Created by Pavel Playerz0redd on 19.03.26.
//

import Foundation


struct LoginDto: Codable {
    let email: String
    let password: String
}

struct RegisterDto: Codable {
    let name: String
    let email: String
    let password: String
}
