//
//  MovieListModel.swift
//  moviehub-iOS
//
//  Created by Pavel Playerz0redd on 19.04.26.
//

import Foundation

struct MovieListModel: Hashable, Equatable {
    let id: Int
    let apiId: Int
    let title: String
    let genreId: Int?
    let posterPath: String
    let releaseDate: Date
    let voteAverage: Double
    var rating: Int?
    var comment: String?
    
    var status: WatchStatus
    
    enum WatchStatus: String, Decodable {
        case liked
        case disliked
        case viewed
    }
}

extension MovieListModel {
    init(from dto: MoviesListDTO.MovieDTO) {
        self.id = dto.id
        self.genreId = dto.genreId
        self.posterPath = (dto.posterPath ?? "")
        self.releaseDate = dto.releaseDate
        self.title = dto.title
        self.voteAverage = dto.voteAverage
        self.status = .init(from: dto.status ?? .liked)
        self.apiId = dto.apiId
        self.comment = dto.comment
        self.rating = dto.rating
    }
}

extension MovieListModel.WatchStatus {
    init(from dto: MoviesListDTO.MovieDTO.WatchStatus) {
        self = switch dto {
        case .liked:
                .liked
        case .disliked:
                .disliked
        case .viewed:
                .viewed
        }
    }
}
