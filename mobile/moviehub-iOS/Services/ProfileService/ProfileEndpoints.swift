//
//  ProfileEndpoints.swift
//  moviehub-iOS
//
//  Created by Pavel Playerz0redd on 25.04.26.
//

import Foundation

enum ProfileEndpoints: IEndpoint {
    
    case stats
    
    private static let BASE_URL = "http://localhost:"
    private static let BASE_PORT = 8000
    private static let API_PREFIX = "api/v1/users/"
    
    private var urlStart: String {
        Self.BASE_URL + String(Self.BASE_PORT) + "/" + Self.API_PREFIX
    }
    
    private var path: String {
        switch self {
        case .stats:        "movies/statistic"
        }
    }
    
    var httpMethod: HttpMethod {
        switch self {
        case .stats:    .get
        }
    }
    
    var url: URL? {
        var components: URLComponents? = .init(string: urlStart + path)
        return components?.url
    }
}
