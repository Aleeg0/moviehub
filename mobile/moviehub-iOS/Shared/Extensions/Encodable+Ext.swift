//
//  Encodable+Ext.swift
//  moviehub-iOS
//
//  Created by Pavel Playerz0redd on 8.04.26.
//

import Foundation

extension Encodable {
    var queryItems: [URLQueryItem] {
        guard let data = try? JSONEncoder().encode(self),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return []
        }
        
        return json.compactMap { key, value in
            if let array = value as? [Any] {
                let stringValue = array.map { "\($0)" }.joined(separator: "|")
                return URLQueryItem(name: key, value: stringValue)
            }
            
            if let number = value as? NSNumber, CFGetTypeID(number) == CFBooleanGetTypeID() {
                return URLQueryItem(name: key, value: number.boolValue ? "true" : "false")
            }
            
            return URLQueryItem(name: key, value: "\(value)")
        }
    }
}


