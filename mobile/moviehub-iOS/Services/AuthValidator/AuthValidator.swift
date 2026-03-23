//
//  AuthValidator.swift
//  moviehub-iOS
//
//  Created by Pavel Playerz0redd on 21.03.26.
//

import Foundation

struct LoginDependency {
    let email: String
    let password: String
}

extension LoginDependency {
    init(from authModel: AuthModel) {
        self.email = authModel.email
        self.password = authModel.password
    }
}

struct RegisterDependency {
    let email: String
    let name: String
    let password: String
    let confirmPassword: String
}

extension RegisterDependency {
    init(from authModel: AuthModel) {
        self.email = authModel.email
        self.name = authModel.name
        self.password = authModel.password
        self.confirmPassword = authModel.confirmPassword
    }
}

protocol IAuthValidator {
    
    func getAuthErrors(dependency: LoginDependency) -> [IAuthValidationError]
    func getRegisterErrors(dependency: RegisterDependency) -> [IAuthValidationError]
    func checkEmail(email: String) -> [IAuthValidationError]
    
}

final class AuthValidator: IAuthValidator {
    
    func getAuthErrors(dependency: LoginDependency) -> [any IAuthValidationError] {
        return checkEmail(email: dependency.email) + checkPassword(password: dependency.password, type: .password)
    }
    
    func getRegisterErrors(dependency: RegisterDependency) -> [any IAuthValidationError] {
        return checkName(name: dependency.name) + checkEmail(email: dependency.email) + checkPassword(password: dependency.password, type: .password) + checkPassword(password: dependency.confirmPassword, type: .confirmPassword) + checkPasswordsMatch(password: dependency.password, confirmPassword: dependency.confirmPassword)
    }
    
    private func checkName(name: String) -> [any IAuthValidationError] {
        
        var errors: [any IAuthValidationError] = []
        
        
        if name.isEmpty {
            errors.append(AuthValidationError.nameError(.empty))
        }
        else if name.count < 3 {
            errors.append(AuthValidationError.nameError(.tooShort))
        }
        if name.count > 10 {
            errors.append(AuthValidationError.nameError(.tooLong))
        }
        
        return errors
    }
    
    func checkEmail(email: String) -> [any IAuthValidationError] {
        
        var errors: [any IAuthValidationError] = []
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        if email.isEmpty {
            errors.append(AuthValidationError.emailError(.empty))
        }
        else if !emailPred.evaluate(with: email) {
            errors.append(AuthValidationError.emailError(.formatError))
        }
        
        return errors
        
    }
    
    private func checkPassword(password: String, type: FieldType) -> [any IAuthValidationError] {
        var errors: [any IAuthValidationError] = []
        
        if password.isEmpty {
            errors.append(AuthValidationError.passwordError(.empty, type))
        }
        else if password.count < 3 {
            errors.append(AuthValidationError.passwordError(.tooShort, type))
        }
        if password.count > 20 {
            errors.append(AuthValidationError.passwordError(.tooLong, type))
        }
        
        return errors
    }
    
    private func checkPasswordsMatch(password: String, confirmPassword: String) -> [any IAuthValidationError] {
        var errors: [any IAuthValidationError] = []
        
        if password != confirmPassword {
            errors.append(AuthValidationError.passwordError(.passwordMismatch, .password))
            errors.append(AuthValidationError.passwordError(.passwordMismatch, .confirmPassword))
        }
        
        return errors
    }
    
    
    
    
    
    
}
