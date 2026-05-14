//
//  MovieListDTO.swift
//  moviehub-iOS
//
//  Created by Pavel Playerz0redd on 8.04.26.
//

import Foundation

struct MovieDTO: Decodable {
    let id: Int
    let genreIds: [Int]
    let originalTitle: String
    let overview: String
    let backdropPath: String?
    let posterPath: String?
    let releaseDate: Date
    let title: String
    let voteAverage: Double
    
    enum CodingKeys: String, CodingKey {
        case id
        case genreIds = "genre_ids"
        case originalTitle = "original_title"
        case overview
        case backdropPath = "backdrop_path"
        case posterPath = "poster_path"
        case releaseDate = "release_date"
        case title
        case voteAverage = "vote_average"
    }
}
