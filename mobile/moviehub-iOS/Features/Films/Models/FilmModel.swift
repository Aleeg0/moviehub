//
//  FilmModel.swift
//  moviehub-iOS
//
//  Created by Pavel Playerz0redd on 6.04.26.
//

import Foundation

struct FilmModel: Hashable, Identifiable {
    let id: Int
    let title: String
    let backdropPath: String?
    let posterPath: String?
    let rating: Double
    let releaseDate: Date
    let genres: [Int]
    
    var image: String? {
        if let backdropPath = self.backdropPath {
            "https://image.tmdb.org/t/p/original" + backdropPath
        }
        else if let posterPath = self.posterPath {
            "https://image.tmdb.org/t/p/original" + posterPath
        }
        else {
            nil
        }
    }
}

extension FilmModel {
    init(from dto: MovieDTO) {
        self.id = dto.id
        self.backdropPath = dto.backdropPath
        self.posterPath = dto.posterPath
        self.title = dto.title
        self.rating = dto.voteAverage
        self.releaseDate = dto.releaseDate
        self.genres = dto.genreIds
    }
}
