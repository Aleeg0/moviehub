//
//  MovieListDTO.swift
//  moviehub-iOS
//
//  Created by Pavel Playerz0redd on 19.04.26.
//

import Foundation


struct MoviesListDTO: Decodable {
    
    let movies: [MovieDTO]
    
    struct MovieDTO: Decodable {
        let id: Int
        let apiId: Int
        let title: String
        let genreId: Int?
        let posterPath: String?
        let releaseDate: Date
        let voteAverage: Double
        let status: WatchStatus?
        let rating: Int?
        let comment: String?
        
        enum WatchStatus: String, Decodable {
            case liked
            case disliked
            case viewed
        }
        
        enum CodingKeys: String, CodingKey {
            case id
            case apiId = "externalId"
            case title
            case genreId
            case posterPath
            case releaseDate
            case voteAverage
            case status
            case rating
            case comment
        }
    }
}
