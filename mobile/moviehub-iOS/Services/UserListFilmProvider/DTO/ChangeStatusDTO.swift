//
//  ChangeStatusDTO.swift
//  moviehub-iOS
//
//  Created by Pavel Playerz0redd on 10.05.26.
//

import Foundation

struct ChangeStatusDTO: Encodable {
    let status: Status
    let comment: String?
    let rating: Int?
    
    enum Status: String, Encodable {
        case liked
        case disliked
        case viewed
    }
}

extension ChangeStatusDTO {
    init(status: FilmsViewModel.SwipeStatus, comment: String?, rating: Int?) {
        self.comment = comment
        self.rating = rating
        switch status {
        case .liked:
            self.status = .liked
        case .disliked:
            self.status = .disliked
        case .viewed:
            self.status = .viewed
        }
    }
}
