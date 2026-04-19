//
//  FilmDescriptionModel.swift
//  moviehub-iOS
//
//  Created by Pavel Playerz0redd on 9.04.26.
//

import Foundation

struct FilmDetailsModel {
    let id: Int
    let genres: [GenreModel]
    let overview: String
    let releaseTime: Date
    let runtime: Int
    let title: String
    let voteAverage: Double
    let budget: Int
    let isAdult: Bool
    let backdropImage: String?
    let posterImage: String?
    let originCountry: String
    let hasVideo: Bool
    let originalTitle: String
    
    var image: String? {
        if let backdropImage = self.backdropImage {
            "https://image.tmdb.org/t/p/original" + backdropImage
        }
        else if let posterImage = self.posterImage {
            "https://image.tmdb.org/t/p/original" + posterImage
        }
        else {
            nil
        }
    }
}

extension FilmDetailsModel {
    init(from dto: FilmDetailsDTO) {
        self.id = dto.id
        self.genres = dto.genres.map( {GenreModel(from: $0)} )
        self.backdropImage = dto.backdropPath
        self.overview = dto.overview
        self.releaseTime = dto.releaseDate
        self.runtime = dto.runtime
        self.title = dto.title
        self.voteAverage = dto.voteAverage
        self.budget = dto.budget
        self.isAdult = dto.isAdult
        self.posterImage = dto.posterPath
        self.originCountry = dto.originCountry.first ?? "no"
        self.hasVideo = dto.hasVideo
        self.originalTitle = dto.originalTitle
    }
}
