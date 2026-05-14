//
//  FilmsEndpoints.swift
//  moviehub-iOS
//
//  Created by Pavel Playerz0redd on 8.04.26.
//

import Foundation

enum FilmsEndpoints: IEndpoint {
    
    case discoverMovies(DiscoverMoviesParams)
    case genres(language: DiscoverMoviesParams.DescriptionLanguage)
    case details(id: Int, language: DiscoverMoviesParams.DescriptionLanguage)
    case images(filmId: Int)
    case reviews(filmId: Int, page: Int)
    
    private static let PROTOCOL = "https://"
    private static let BASE_URL = "api.themoviedb.org/"
    private static let API_PREFIX = "3/"
    static let TOKEN = "eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIxZGFlMDdiMjM3OTNlN2RhY2VjNGM4ODFlMjMxMDJlMiIsIm5iZiI6MTc1Mzc0MDczMi45MTUsInN1YiI6IjY4ODdmNWJjZTUxNzYxMGU5M2Y3OTRiMCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.E4QBj42GAlgVdGqHgBUUmw3YB0MJDrARPDxySjnYMZg"
    
    private var urlStart: String {
        Self.PROTOCOL + Self.BASE_URL + Self.API_PREFIX
    }
    
    private var urlPath: String {
        switch self {
        case .discoverMovies:
            "discover/movie"
        case .genres:
            "genre/movie/list"
        case .details(let id, _):
            "/movie/\(id)"
        case .images(let id):
            "/movie/\(id)/images"
        case .reviews(let filmId, _):
            "/movie/\(filmId)/reviews"
        }
    }
    
    var httpMethod: HttpMethod {
        switch self {
        case .discoverMovies:
                .get
        case .genres:
                .get
        case .details:
                .get
        case .images:
                .get
        case .reviews:
                .get
        }
    }
    
    var url: URL? {
        var components: URLComponents? = .init(string: self.urlStart + self.urlPath)
        
        var queryItems: [URLQueryItem] = []
        
        switch self {
        case .discoverMovies(let params):
            queryItems = params.queryItems
        case .genres(let language):
            queryItems.append(.init(name: "language", value: language.rawValue))
        case .details(_, let language):
            queryItems.append(.init(name: "language", value: language.rawValue))
        case .images:
            break
        case .reviews(_, let page):
            queryItems.append(.init(name: "page", value: "\(page)"))
        }
        
        components?.queryItems = queryItems
        
        return components?.url
    }
    
    
    
    struct DiscoverMoviesParams: Encodable {
        let language: DescriptionLanguage?
        let page: Int?
        let sortBy: SortCategory?
        let includeAdult: Bool?
        let watchRegion: WatchRegion?
        let watchProviderIds: Set<Int>?
        let genreIds: Set<Int>?
        let runtimeGte: Int?
        let runtimeLte: Int?
        
        enum CodingKeys: String, CodingKey {
            case language
            case page
            case sortBy = "sort_by"
            case includeAdult = "include_adult"
            case watchRegion = "watch_region"
            case watchProviderIds = "with_watch_providers"
            case genreIds = "with_genres"
            case runtimeGte = "with_runtime.gte"
            case runtimeLte = "with_runtime.lte"
        }
        
        
        enum WatchRegion: String, Encodable {
            case USA = "USA"
            case RU = "RU"
        }
        
        enum SortCategory: String, Encodable {
            case releaseDate = "primary_release_date.desc"
            case popularity = "popularity.desc"
            case averageVote = "vote_average.desc"
            
        }
        
        enum DescriptionLanguage: String, Encodable {
            case eng = "en-US"
            case ru = "ru-RU"
            
        }
    }
}
