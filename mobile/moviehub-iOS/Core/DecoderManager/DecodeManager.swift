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
    
    init() {
        let decoder = JSONDecoder()
        
        let fullFormatter = DateFormatter()
            fullFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            fullFormatter.locale = Locale(identifier: "en_US_POSIX")
            
            let shortFormatter = DateFormatter()
            shortFormatter.dateFormat = "yyyy-MM-dd"
            shortFormatter.locale = Locale(identifier: "en_US_POSIX")
            
            decoder.dateDecodingStrategy = .custom { decoder in
                let container = try decoder.singleValueContainer()
                let dateString = try container.decode(String.self)
                

                if let date = fullFormatter.date(from: dateString) {
                    return date
                }
 
                if let date = shortFormatter.date(from: dateString) {
                    return date
                }
                
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Неверный формат даты: \(dateString)")
            }
        
        self.decoder = decoder
    }
    
    
    func decode<T: Decodable>(data: Data) -> T? {
        do {
            return try? decoder.decode(T.self, from: data)
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
