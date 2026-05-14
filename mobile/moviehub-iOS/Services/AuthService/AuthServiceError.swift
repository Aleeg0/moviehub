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
    case resetPasswordError(NetworkError)
    case unknown
    
    var description: LocalizedStringResource {
        switch self {
        case .loginError(let networkError):
            switch networkError {
            case .serverError(let statusCode):
                statusCode == 400 ? "Пользователь не найден" : networkError.description
            case .networkError:
                networkError.description
            case .unknown:
                networkError.description
            }
        case .registerError(let networkError):
            switch networkError {
            case .serverError(let statusCode):
                statusCode == 400 ? "Пользователь уже существует" : networkError.description
            case .networkError:
                networkError.description
            case .unknown:
                networkError.description
            }
        case .unknown:
            "Неизвестная ошибка :("
        case .resetPasswordError(let networkError):
            switch networkError {
            case .serverError(let statusCode):
                statusCode == 404 ? "Пользователь не найден" : networkError.description
            case .networkError:
                networkError.description
            case .unknown:
                networkError.description
            }
        }
    }
}
