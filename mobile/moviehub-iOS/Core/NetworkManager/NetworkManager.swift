//
//  NetworkManager.swift
//  moviehub-iOS
//
//  Created by Pavel Playerz0redd on 12.03.26.
//

import Foundation

protocol INetworkManager {
    func sendRequest<T: IEndpoint>(endpoint: T, body: Data?) async throws(NetworkError) -> Data?
}

struct NetworkManager: INetworkManager {
    
    func sendRequest<T: IEndpoint>(endpoint: T, body: Data?) async throws(NetworkError) -> Data? {
        guard let url = endpoint.url else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.httpMethod.toString
        request.httpBody = body
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
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
