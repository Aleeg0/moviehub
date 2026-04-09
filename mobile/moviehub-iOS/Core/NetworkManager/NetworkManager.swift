//
//  NetworkManager.swift
//  moviehub-iOS
//
//  Created by Pavel Playerz0redd on 12.03.26.
//

import Foundation

protocol INetworkManager {
    func sendRequest<T: IEndpoint>(endpoint: T, body: Data?, authorization: NetworkManager.Authorization?) async throws(NetworkError) -> Data?
}

struct NetworkManager: INetworkManager {
    
    enum Authorization {
        case bearer(token: String)
        
        var httpHeader: String {
            self.title + " " + self.token
        }
        
        private var title: String {
            switch self {
            case .bearer:
                "Bearer"
            }
        }
        
        private var token: String {
            switch self {
            case .bearer(let token):
                token
            }
        }
    }
    
    func sendRequest<T: IEndpoint>(endpoint: T, body: Data?, authorization: Authorization?) async throws(NetworkError) -> Data? {
        guard let url = endpoint.url else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.httpMethod.toString
        request.httpBody = body
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        if let auth = authorization {
            request.addValue(auth.httpHeader, forHTTPHeaderField: "Authorization")
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else { throw NetworkError.unknown(message: "No response") }
            
            guard (200...300).contains(httpResponse.statusCode) else {
                throw NetworkError.serverError(statusCode: httpResponse.statusCode)
            }
            
            return data
            
        } catch let error as NetworkError {
            throw error
        }
        catch let error {
            print(error.localizedDescription)
            throw .networkError(error)
        }
    }
    
    
}
