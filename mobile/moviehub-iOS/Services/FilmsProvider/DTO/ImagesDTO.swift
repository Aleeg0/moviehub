//
//  ImagesDTO.swift
//  moviehub-iOS
//
//  Created by Pavel Playerz0redd on 13.04.26.
//

import Foundation

struct ImagesDTO: Decodable {
    
    let backdrops: [ImageDTO]
    let posters: [ImageDTO]
    let logos: [ImageDTO]
    
    struct ImageDTO: Decodable {
        let height: Double
        let width: Double
        let filePath: String
        let aspectRatio: Double
        
        enum CodingKeys: String, CodingKey {
            case height
            case width
            case filePath = "file_path"
            case aspectRatio = "aspect_ratio"
        }
    }
}
