//
//  ReviewDTO.swift
//  moviehub-iOS
//
//  Created by Pavel Playerz0redd on 13.04.26.
//

import Foundation

struct ReviewResponseDTO: Decodable {
    let page: Int
    let results: [ReviewDTO]
    let totalPages: Int
    
    
    
    struct ReviewDTO: Decodable {
        let author: String
        let authorDetails: AuthorDTO
        let content: String
        let createdAt: Date
        let id: String
        
        struct AuthorDTO: Decodable {
            let name: String
            let username: String
            let avatarPath: String?
            
            enum CodingKeys: String, CodingKey {
                case name
                case username
                case avatarPath = "avatar_path"
            }
        }
        
        enum CodingKeys: String, CodingKey {
            case author
            case authorDetails = "author_details"
            case content
            case createdAt = "created_at"
            case id
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case page
        case results
        case totalPages = "total_pages"
    }
}
