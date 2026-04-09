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
    
    var image: String? {
        if let image = self.backdropImage {
            image
        } else if let image = self.posterImage {
            image
        } else {
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
        self.releaseTime = dto.realeaseDate
        self.runtime = dto.runtime
        self.title = dto.title
        self.voteAverage = dto.voteAverage
        self.budget = dto.budget
        self.isAdult = dto.isAdult
        self.posterImage = dto.posterPath
        self.originCountry = dto.originCountry
        self.hasVideo = dto.hasVideo
    }
}
