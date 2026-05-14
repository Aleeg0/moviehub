//
//  ProviderEndpoints.swift
//  moviehub-iOS
//
//  Created by Pavel Playerz0redd on 10.05.26.
//

import Foundation

enum ProviderEndpoints: IEndpoint {
    
    case providers
    case fetchProviders
    case uploadProviders
    
    private static let PROTOCOL = "https://"
    private static let BASE_URL = "api.themoviedb.org/"
    private static let API_PREFIX = "3/"
    static let TOKEN = "eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIxZGFlMDdiMjM3OTNlN2RhY2VjNGM4ODFlMjMxMDJlMiIsIm5iZiI6MTc1Mzc0MDczMi45MTUsInN1YiI6IjY4ODdmNWJjZTUxNzYxMGU5M2Y3OTRiMCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.E4QBj42GAlgVdGqHgBUUmw3YB0MJDrARPDxySjnYMZg"
    
    private static let BASE_URL_LOCAL = "http://localhost:8000/api/v1/"
    
    private var urlStart: String {
        Self.PROTOCOL + Self.BASE_URL + Self.API_PREFIX
    }
    
    private var urlPath: String {
        switch self {
        case .providers:
            "watch/providers/movie"
        case .fetchProviders:
            "users/movie-services"
        case .uploadProviders:
            "users/movie-services"
        }
    }
    
    var httpMethod: HttpMethod {
        switch self {
        case .providers:        .get
        case .fetchProviders:   .get
        case .uploadProviders:  .post
        }
    }
    
    var url: URL? {
        var components: URLComponents?
        switch self {
        case .providers:
            components = .init(string: self.urlStart + self.urlPath)
        case .fetchProviders:
            components = .init(string: Self.BASE_URL_LOCAL + self.urlPath)
        case .uploadProviders:
            components = .init(string: Self.BASE_URL_LOCAL + self.urlPath)
        }
        return components?.url
    }
}
