//
//  NetworkManager.swift
//  moviehub-iOS
//
//  Created by Pavel Playerz0redd on 12.03.26.
//

import Foundation

enum RequestType {
    case get
    case post
    
    var toString: String {
        switch self {
        case .get:        "get"
        case .post:       "post"
        }
    }
}

protocol INetworkManager {
    func sendRequest(type: RequestType, url: String, body: Data?) async throws -> Data?
}

struct NetworkManager: INetworkManager {
    func sendRequest(type: RequestType, url: String, body: Data?) async throws -> Data? {
        guard let url = URL(string: url) else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = type.toString
        request.httpBody = body
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else { return nil }
        
        return data
    }
    
    
}
