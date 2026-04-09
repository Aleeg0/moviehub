//
//  FilmDetailsDTO.swift
//  moviehub-iOS
//
//  Created by Pavel Playerz0redd on 9.04.26.
//

import Foundation

struct FilmDetailsDTO: Decodable {
    let id: Int
    let isAdult: Bool
    let backdropPath: String?
    let posterPath: String?
    let budget: Int
    let genres: [GenreDTO.Genre]
    let originCountry: String
    let overview: String
    let realeaseDate: Date
    let runtime: Int
    let title: String
    let voteAverage: Double
    let hasVideo: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case isAdult = "adult"
        case backdropPath = "backdrop_path"
        case posterPath = "poster_path"
        case budget
        case genres
        case originCountry = "origin_country"
        case overview
        case realeaseDate = "release_date"
        case runtime
        case title
        case voteAverage = "vote_average"
        case hasVideo = "video"
    }
}
