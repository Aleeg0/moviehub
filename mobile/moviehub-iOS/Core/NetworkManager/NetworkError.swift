//
//  NetworkError.swift
//  moviehub-iOS
//
//  Created by Pavel Playerz0redd on 31.03.26.
//

import Foundation

enum NetworkError: Error {
    case serverError(statusCode: Int)
    case networkError(Error)
    case unknown(message: LocalizedStringResource)
    
    var description: LocalizedStringResource {
        switch self {
        case .serverError(let statusCode):
            "Server error code \(statusCode)"
        case .networkError(let error):
            "Error: \(error.localizedDescription)"
        case .unknown(let message):
            message
        }
    }
}
