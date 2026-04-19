//
//  ReviewsModel.swift
//  moviehub-iOS
//
//  Created by Pavel Playerz0redd on 13.04.26.
//

import Foundation


struct ReviewModel: Hashable {
    let id: String
    let author: String
    let content: String
    let createdAt: Date
    let authorDetails: AuthorDetailsModel
    
    struct AuthorDetailsModel: Hashable {
        let name: String
        let username: String
        let avatarPath: String?
        
        var avatarUrl: URL? {
            if let path = self.avatarPath {
                .init(string: "https://image.tmdb.org/t/p/original" + path)
            } else {
                nil
            }
        }
    }
    
}

extension ReviewModel {
    init(from dto: ReviewResponseDTO.ReviewDTO) {
        self.id = dto.id
        self.author = dto.author
        self.content = dto.content
        self.createdAt = dto.createdAt
        self.authorDetails = .init(from: dto.authorDetails)
    }
}

extension ReviewModel.AuthorDetailsModel {
    init(from dto: ReviewResponseDTO.ReviewDTO.AuthorDTO) {
        self.avatarPath = dto.avatarPath
        self.name = dto.name
        self.username = dto.username
    }
}
