//
//  DecodeManager.swift
//  moviehub-iOS
//
//  Created by Pavel Playerz0redd on 19.03.26.
//

import Foundation

protocol IDecodeManager {
    func decode<T: Decodable>(data: Data) -> T?
    func encode<T: Encodable>(data: T) -> Data?
}

struct DecodeManager: IDecodeManager {
    
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    
    init() {
        let decoder = JSONDecoder()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        decoder.dateDecodingStrategy = .formatted(formatter)
        
        self.decoder = decoder
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .formatted(formatter)
        self.encoder = encoder
    }
    
    
    func decode<T: Decodable>(data: Data) -> T? {
        do {
            return try? decoder.decode(T.self, from: data)
        } catch let error {
            
        }
    }
    
    func encode<T: Encodable>(data: T) -> Data? {
        do {
            return try? encoder.encode(data)
        } catch let error {
            
        }
    }
}
