//
//  SwipeMovieDTO.swift
//  moviehub-iOS
//
//  Created by Pavel Playerz0redd on 21.04.26.
//

import Foundation

struct SwipeMovieDTO: Encodable {
    let action: Action
    let movie: MovieDTO
    let status: Status
    
    struct MovieDTO: Encodable {
        let externalId: Int
        let title: String
        let posterPath: String
        let releaseDate: Date
        let voteAverage: Double
        
        enum CodingKeys: String, CodingKey {
            case externalId = "external_id"
            case title
            case posterPath = "poster_path"
            case releaseDate = "release_date"
            case voteAverage = "vote_average"
        }
    }
    
    enum Status: String, Encodable {
        case liked
        case disliked
        case viewed
    }
    
    enum Action: String, Encodable {
        case movie = "movie"
    }
}

extension SwipeMovieDTO {
    init(from movie: FilmModel, status: FilmsViewModel.SwipeStatus) {
        self.action = .movie
        self.movie = .init(externalId: movie.id, title: movie.title, posterPath: movie.image ?? "", releaseDate: movie.releaseDate, voteAverage: movie.rating)
        
        self.status = switch status {
        case .liked:      .liked
        case .disliked:   .disliked
        case .viewed:     .viewed
        }
    }
}
