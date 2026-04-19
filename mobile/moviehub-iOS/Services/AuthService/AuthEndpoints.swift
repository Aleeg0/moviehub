//
//  AuthEndpoints.swift
//  moviehub-iOS
//
//  Created by Pavel Playerz0redd on 31.03.26.
//

import Foundation

enum AuthEndpoints: IEndpoint {
    
    case login
    case register
    case logout
    case askResetCode
    case verifyCode
    case resetPassword
    case agreement
    
    private static let BASE_URL = "http://localhost:"
    private static let BASE_PORT = 8000
    private static let API_PREFIX = "api/v1/users/"
    
    private var urlStart: String {
        Self.BASE_URL + String(Self.BASE_PORT) + "/" + Self.API_PREFIX
    }
    
    private var path: String {
        switch self {
        case .login:             "login"
        case .register:          "register"
        case .logout:            "logout"
        case .askResetCode:       "reset/mail"
        case .verifyCode:         "reset/verify"
        case .resetPassword:      "reset/password"
        case .agreement:          "agreement"
        }
    }
    
    var httpMethod: HttpMethod {
        switch self {
        case .login:              .post
        case .register:           .post
        case .logout:             .post
        case .askResetCode:       .post
        case .verifyCode:         .post
        case .resetPassword:      .patch
        case .agreement:          .get
        }
    }
    
    var url: URL? {
        .init(string: urlStart + self.path)
    }
}
