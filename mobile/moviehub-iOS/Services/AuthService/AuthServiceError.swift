//
//  AuthServiceError.swift
//  moviehub-iOS
//
//  Created by Pavel Playerz0redd on 31.03.26.
//

import Foundation

enum AuthServiceError: Error, Equatable {
    
    static func == (lhs: AuthServiceError, rhs: AuthServiceError) -> Bool {
        switch (lhs, rhs) {
        case (.loginError, .loginError), (.registerError, .registerError), (.unknown, .unknown): true
        default: false
        }
    }
    
    case loginError(NetworkError)
    case registerError(NetworkError)
    case unknown
    
    var description: LocalizedStringResource {
        switch self {
        case .loginError(let networkError):
            switch networkError {
            case .serverError(let statusCode):
                statusCode == 400 ? "User not found" : networkError.description
            case .networkError:
                networkError.description
            case .unknown:
                networkError.description
            }
        case .registerError(let networkError):
            networkError.description
        case .unknown:
            "Unknown error occured"
        }
    }
}
