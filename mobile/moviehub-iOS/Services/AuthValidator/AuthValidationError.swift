//
//  AuthValidationError.swift
//  moviehub-iOS
//
//  Created by Pavel Playerz0redd on 21.03.26.
//

import Foundation

protocol IAuthValidationError: Error {
    var description: LocalizedStringResource { get }
}

enum AuthValidationError: IAuthValidationError, Equatable {
    
    case nameError(NameError)
    case emailError(EmailError)
    case passwordError(PasswordError, FieldType)
    
    var description: LocalizedStringResource {
        switch self {
        case .nameError(let nameError):
            nameError.description
        case .emailError(let emailError):
            emailError.description
        case .passwordError(let passwordError, _):
            passwordError.description
        }
    }
    
    enum NameError: IAuthValidationError {
        case empty
        case tooShort
        case tooLong
        
        var description: LocalizedStringResource {
            switch self {
            case .tooShort:
                "Name is too short"
            case .tooLong:
                "Name is too long"
            case .empty:
                "Name is empty"
            }
        }
    
    }
    
    enum EmailError: IAuthValidationError {
        case empty
        case formatError
        
        var description: LocalizedStringResource {
            switch self {
            case .formatError:
                "Not correct email"
            case .empty:
                "Email is empty"
            }
        }
    }
    
    enum PasswordError: IAuthValidationError {
        case empty
        case tooShort
        case tooLong
        case passwordMismatch
        
        var description: LocalizedStringResource {
            switch self {
            case .tooShort:
                "Password is too short"
            case .tooLong:
                "Password is too long"
            case .passwordMismatch:
                "Passwords are not equal"
            case .empty:
                "Password is empty"
            }
        }
    }
}
