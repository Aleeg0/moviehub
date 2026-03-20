//
//  AuthViewModel.swift
//  moviehub-iOS
//
//  Created by Pavel Playerz0redd on 19.03.26.
//

import Foundation
import Combine

final class AuthViewModel: ObservableObject {
    
    @Published var model: AuthModel
    @Published var authType: AuthType = .login
    
    private let service: IAuthService
    
    init(service: IAuthService) {
        self.model = .init()
        self.service = service
    }
    
    func changeAuthType() {
        switch authType {
        case .login:         authType = .register
        case .register:      authType = .login
        }
    }
    
    func onAuth() {
        switch authType {
        case .login:        login()
        case .register:     register()
        }
    }
    
    func login() {
        
    }
    
    func register() {
        
    }
    
}

extension AuthViewModel {
    
    enum FieldType {
        case name
        case email
        case password
        case confirmPassword
        
        var caption: LocalizedStringResource {
            switch self {
            case .name:                 "Name"
            case .email:                "Email"
            case .password:             "Password"
            case .confirmPassword:      "Confirm Password"
            }
        }
        
        var prompt: LocalizedStringResource {
            switch self {
            case .name:                "Your Name"
            case .email:               "Your Email"
            case .password:            "Your Password"
            case .confirmPassword:     "Confirm Your Password"
            }
        }
        
        var isSecured: Bool {
            switch self {
            case .name:                false
            case .email:               false
            case .password:            true
            case .confirmPassword:     true
            }
        }
    }
    
    enum AuthType {
        case login
        case register
        
        var typePickerCaption: LocalizedStringResource {
            switch self {
            case .login:             "Login"
            case .register:          "Register"
            }
        }
        
        var actionButtonCaption: LocalizedStringResource {
            switch self {
            case .login:           "Login"
            case .register:        "Register"
            }
        }
    }
    
}
