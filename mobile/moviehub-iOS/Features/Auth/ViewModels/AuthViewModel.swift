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
    @Published var validationErrors: [AuthValidationError] = []
    @Published var isResetingPassword: Bool = false
    @Published var resetPasswordStage: ResetPasswordStage = .gettingEmail
    @Published var resetCode: String = ""
    @Published var offset: CGFloat = .zero
    
    @Published var emailForResetError: AuthValidationError?
    @Published var remainingTime = 30
    
    private var timer: Cancellable?
    
    private let authService: IAuthService
    private let validator: IAuthValidator
    private var cancellables: Set<AnyCancellable> = []
    
    init(authService: IAuthService, validator: IAuthValidator) {
        self.model = .init()
        self.authService = authService
        self.validator = validator
        
        self._resetCode.projectedValue.sink { code in
            self.updateResetState(resetCode: code)
        }
        .store(in: &cancellables)

    }
    
    var getRemainingTime: LocalizedStringResource {
        if remainingTime > 0 {
            "(\(remainingTime) seconds...)"
        } else {
            ""
        }
    }
    
    private func timerStart() {
        self.remainingTime = 30
        self.timer?.cancel()
        
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                if self?.remainingTime ?? 0 > 0 {
                    self?.remainingTime -= 1
                } else {
                    self?.timer?.cancel()
                }
                
            }
    }
    
    func resendCode() {
        timerStart()
    }
    
    private func updateResetState(resetCode: String) {
        
        guard case .enterCode = self.resetPasswordStage else { return }
        
        if resetCode.count < 5 {
            self.resetPasswordStage = .enterCode(.inProgress(index: resetCode.count - 1))
        } else if resetCode == "12345" {
            self.resetPasswordStage = .enterCode(.success)
        } else {
            self.resetPasswordStage = .enterCode(.error)
        }
    }
    
    func changeAuthType() {
        self.validationErrors = []
        switch authType {
        case .login:         authType = .register
        case .register:      authType = .login
        }
    }
    
    func forgotPassword() {
        self.isResetingPassword = true
    }
    
    func hasError(field: FieldType) -> AuthValidationError? {
        switch field {
        case .name:
            validationErrors.first { error in
                if case .nameError = error {
                    return true
                }
                return false
            }
        case .email:
            validationErrors.first { error in
                if case .emailError = error {
                    return true
                }
                return false
            }
        case .password:
            validationErrors.first { error in
                if case .passwordError( _, let fieldType) = error, fieldType == .password {
                    return true
                }
                return false
            }
        case .confirmPassword:
            validationErrors.first { error in
                if case .passwordError( _, let fieldType) = error, fieldType == .confirmPassword {
                    return true
                }
                return false
            }
        }
    }
    
    func onOTPSend() {
        self.emailForResetError = checkEmail(email: model.emailForReset)
        guard self.emailForResetError == nil else { return }
        self.resetPasswordStage = .loadingOTP
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.resetPasswordStage = .enterCode(.inProgress(index: 0))
            self.timerStart()
        }
    }
    
    func checkEmail(email: String) -> AuthValidationError? {
        validator.checkEmail(email: email).first as? AuthValidationError
    }
    
    private func validateLogin() {
        self.validationErrors = validator.getAuthErrors(dependency: .init(from: model)) as! [AuthValidationError]
    }
    
    private func validateRegister() {
        self.validationErrors = validator.getRegisterErrors(dependency: .init(from: model)) as! [AuthValidationError]
    }
    
    func getDigitByIndex(index: Int) -> String? {
        if index < self.resetCode.count {
            String(self.resetCode[self.resetCode.index(self.resetCode.startIndex, offsetBy: index)])
        } else {
            nil
        }
    }
    
    func onAuth() {
        switch authType {
        case .login:        login()
        case .register:     register()
        }
    }
    
    private func login() {
        validateLogin()
    }
    
    private func register() {
        validateRegister()
    }
    
}

extension AuthViewModel {
    
    enum ResetPasswordStage: Equatable {
        case gettingEmail
        case loadingOTP
        case enterCode(EnterCodeState)
        
        enum EnterCodeState: Equatable {
            case error
            case success
            case inProgress(index: Int)
        }
    }
    
}

extension AuthViewModel {
    
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
