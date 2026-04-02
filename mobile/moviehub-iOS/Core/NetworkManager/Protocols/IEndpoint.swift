//
//  IEndpoint.swift
//  moviehub-iOS
//
//  Created by Pavel Playerz0redd on 31.03.26.
//

import Foundation


protocol IEndpoint {
    var url: URL? { get }
    var httpMethod: HttpMethod { get }
}

enum HttpMethod {
    case get
    case post
    case put
    case delete
    
    var toString: String {
        switch self {
        case .get:        "GET"
        case .post:       "POST"
        case .put:        "PUT"
        case .delete:     "DELETE"
        }
    }
}
