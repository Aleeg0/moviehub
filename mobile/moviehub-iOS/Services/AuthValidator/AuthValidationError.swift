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
                "Имя слишком короткое"
            case .tooLong:
                "Имя слишком длинное"
            case .empty:
                "Пустое имя"
            }
        }
    
    }
    
    enum EmailError: IAuthValidationError {
        case empty
        case formatError
        
        var description: LocalizedStringResource {
            switch self {
            case .formatError:
                "Некорректная почта"
            case .empty:
                "Пустая почта"
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
                "Слишком короткий пароль"
            case .tooLong:
                "Слишком длинный пароль"
            case .passwordMismatch:
                "Пароли не совпали"
            case .empty:
                "Пустой пароль"
            }
        }
    }
}
