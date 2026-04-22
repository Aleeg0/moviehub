//
//  ImagesModel.swift
//  moviehub-iOS
//
//  Created by Pavel Playerz0redd on 13.04.26.
//

import Foundation

protocol IMediaImage: Hashable {
    var url: URL? { get }
    var height: Double { get }
    var width: Double { get }
    var aspectRation: Double { get }
}

struct ImagesModel {
    let backdrops: [ImageModel]
    let posters: [ImageModel]
    let logos: [ImageModel]
    
    
    struct ImageModel: IMediaImage {
        let height: Double
        let width: Double
        let aspectRation: Double
        let filePath: String
        
        var url: URL? {
            .init(string: filePath)
        }
    }
}

extension ImagesModel.ImageModel {
    init(from dto: ImagesDTO.ImageDTO) {
        self.aspectRation = dto.aspectRatio
        self.filePath = "https://image.tmdb.org/t/p/original" + dto.filePath
        self.height = dto.height
        self.width = dto.width
    }
}

extension ImagesModel {
    init(from dto: ImagesDTO) {
        self.backdrops = dto.backdrops.map( {.init(from: $0)} )
        self.posters = dto.posters.map( {.init(from: $0)} )
        self.logos = dto.logos.map( {.init(from: $0)} )
    }
}
