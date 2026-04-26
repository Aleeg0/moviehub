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
        let title: String
        let genreId: Int?
        let posterPath: String?
        let releaseDate: Date
        let voteAverage: Double
        let status: WatchStatus?
        
        enum WatchStatus: String, Decodable {
            case liked
            case disliked
            case viewed
        }
        
        enum CodingKeys: CodingKey {
            case id
            case title
            case genreId
            case posterPath
            case releaseDate
            case voteAverage
            case status
        }
    }
}
