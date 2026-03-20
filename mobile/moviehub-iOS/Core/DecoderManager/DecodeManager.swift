//
//  DecodeManager.swift
//  moviehub-iOS
//
//  Created by Pavel Playerz0redd on 19.03.26.
//

import Foundation

protocol IDecodeManager {
    func decode<T: Decodable>(data: Data) -> T
    func encode<T: Encodable>(data: T) -> Data?
}

struct DecodeManager: IDecodeManager {
    
    func decode<T: Decodable>(data: Data) -> T {
        do {
            return try! JSONDecoder().decode(T.self, from: data)
        } catch let error {
            
        }
    }
    
    func encode<T: Encodable>(data: T) -> Data? {
        do {
            return try? JSONEncoder().encode(data)
        } catch let error {
            
        }
    }
}
