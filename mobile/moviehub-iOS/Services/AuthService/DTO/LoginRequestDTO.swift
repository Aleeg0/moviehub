//
//  LoginRequestDTO.swift
//  moviehub-iOS
//
//  Created by Pavel Playerz0redd on 31.03.26.
//

import Foundation

struct LoginRequestDTO: Encodable {
    let email: String
    let password: String
}
