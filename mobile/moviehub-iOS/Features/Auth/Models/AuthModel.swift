//
//  AuthModel.swift
//  moviehub-iOS
//
//  Created by Pavel Playerz0redd on 19.03.26.
//

import Foundation

struct AuthModel {
    var name: String
    var email: String
    var password: String
    var confirmPassword: String
}

extension AuthModel {
    
    init() {
        self.name = ""
        self.email = ""
        self.confirmPassword = ""
        self.password = ""
    }
    
}
