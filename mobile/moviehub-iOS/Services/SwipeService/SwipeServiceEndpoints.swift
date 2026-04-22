//
//  SwipeServiceEndpoints.swift
//  moviehub-iOS
//
//  Created by Pavel Playerz0redd on 21.04.26.
//

import Foundation

enum SwipeServiceEndpoints: IEndpoint {
    case websocketMovieTracking(refreshToken: String)
    
    private static let PROTOCOL = "ws://"
    private static let BASE_URL = "localhost:8000/ws/v1/"
    
    private var path: String {
        switch self {
        case .websocketMovieTracking:    "movie-tracking"
        }
    }
    
    var startUrl: String {
        Self.PROTOCOL + Self.BASE_URL + path
    }
    
    var httpMethod: HttpMethod {
        switch self {
        case .websocketMovieTracking:      .get
        }
    }
    
    var url: URL? {
        var components: URLComponents? = .init(string: startUrl)
        var queryItems: [URLQueryItem] = []
        
        switch self {
        case .websocketMovieTracking(let refreshToken):
            queryItems.append(.init(name: "token", value: refreshToken))
        }
        
        components?.queryItems = queryItems
        
        return components?.url
    }
    
}
