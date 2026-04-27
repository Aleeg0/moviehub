//
//  MovieListsEndpoints.swift
//  moviehub-iOS
//
//  Created by Pavel Playerz0redd on 24.04.26.
//

import Foundation

enum MovieListsEndpoints: IEndpoint {
    case allMovies
    case refreshTokens
    
    private static let BASE_URL = "http://localhost:"
    private static let BASE_PORT = 8000
    private static let API_PREFIX = "api/v1/"
    
    private var urlStart: String {
        Self.BASE_URL + String(Self.BASE_PORT) + "/" + Self.API_PREFIX
    }
    
    private var path: String {
        switch self {
        case .allMovies:        "users/movies"
        case .refreshTokens:    "auth/refresh"
        }
    }
    
    var httpMethod: HttpMethod {
        switch self {
        case .allMovies:        .get
        case .refreshTokens:    .post
        }
    }
    
    var url: URL? {
        var components: URLComponents? = .init(string: urlStart + path)
        return components?.url
    }
}
