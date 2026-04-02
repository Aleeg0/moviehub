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
        }
    }
    
    var httpMethod: HttpMethod {
        switch self {
        case .login:              .post
        case .register:           .post
        case .logout:             .post
        }
    }
    
    var url: URL? {
        .init(string: urlStart + self.path)
    }
}
