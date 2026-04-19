//
//  VerifyCodeDTO.swift
//  moviehub-iOS
//
//  Created by Pavel Playerz0redd on 10.04.26.
//

import Foundation

struct VerifyCodeDTO: Encodable {
    let email: String
    let code: String
}
