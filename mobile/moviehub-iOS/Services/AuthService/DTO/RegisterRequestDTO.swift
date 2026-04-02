//
//  RegisterRequestDTO.swift
//  moviehub-iOS
//
//  Created by Pavel Playerz0redd on 31.03.26.
//

import Foundation

struct RegisterRequestDTO: Encodable {
    let email: String
    let password: String
    let name: String
}
