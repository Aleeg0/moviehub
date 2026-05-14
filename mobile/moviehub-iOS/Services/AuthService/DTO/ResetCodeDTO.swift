//
//  ResetCodeDTO.swift
//  moviehub-iOS
//
//  Created by Pavel Playerz0redd on 10.04.26.
//

import Foundation

struct ResetCodeDTO: Encodable {
    let resetToken: String
    let email: String
    let newPassword: String
}
