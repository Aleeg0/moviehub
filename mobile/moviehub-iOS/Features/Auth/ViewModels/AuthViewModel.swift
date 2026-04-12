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
    @Published var newPassword: String = ""
    @Published var confirmNewPassword: String = ""
    
    @Published var isAgree = false
    @Published var isAgreeError = false
    
    @Published var resetPasswordValidationError: [IAuthValidationError] = []
    @Published var resetPasswordError: AuthServiceError?
    
    @Published var emailForResetError: AuthValidationError?
    @Published var remainingTime = 30
    @Published var authError: AuthServiceError?
    @Published var isPresentedError: Bool = false
    
    private let onAuthSuccess: () -> Void
    
    private var timer: Cancellable?
    
    private let authService: IAuthService
    private let validator: IAuthValidator
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(authService: IAuthService, validator: IAuthValidator, onAuthSuccess: @escaping () -> Void) {
        self.model = .init()
        self.authService = authService
        self.validator = validator
        self.onAuthSuccess = onAuthSuccess
        
        self._resetCode.projectedValue.sink { code in
            self.updateResetState(resetCode: code)
        }
        .store(in: &cancellables)
        
        self._authError.projectedValue.compactMap({ $0 }).sink { _ in
            self.isPresentedError = true
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
    
    func onAgreeChange() {
        self.isAgree.toggle()
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
        sendCode()
    }
    
    private func updateResetState(resetCode: String) {
        
        guard case .enterCode = self.resetPasswordStage else { return }
        
        if resetCode.count < 5 {
            self.resetPasswordStage = .enterCode(.inProgress(index: resetCode.count - 1))
        } else {
            Task {
                do {
                    try await authService.verifyCode(email: model.emailForReset, code: resetCode)
                    
                    await MainActor.run {
                        self.resetPasswordStage = .enterCode(.success)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            self.resetPasswordStage = .enterNewPassword
                        }
                    }
                } catch let error {
                    await MainActor.run {
                        self.resetPasswordStage = .enterCode(.error)
                    }
                }
            }
        }
    }
    
    func changeAuthType() {
        
        self.authError = nil
        self.validationErrors = []
        self.isAgreeError = false
        
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
    
    func resetPassword() {
        
        self.resetPasswordError = nil
        
        self.resetPasswordValidationError = validatePasswords(password: newPassword, passwordWith: confirmNewPassword)
        
        guard resetPasswordValidationError.isEmpty else { return }
        
        Task {
            do {
                try await authService.resetPassword(email: model.emailForReset, password: newPassword)
                
                await MainActor.run {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.resetPasswordStage = .success
                    }
                }
            } catch let error as AuthServiceError {
                await MainActor.run {
                    self.resetPasswordError = error
                }
            }
        }
    }
    
    func onResetPasswordEnd() {
        self.isResetingPassword = false
        self.resetPasswordStage = .gettingEmail
        self.model.emailForReset = ""
        self.resetCode = ""
        self.newPassword = ""
        self.confirmNewPassword = ""
    }
    
    func onOTPSend() {
        self.emailForResetError = checkEmail(email: model.emailForReset)
        
        self.resetPasswordError = nil
        guard self.emailForResetError == nil else { return }
        
        self.resetPasswordStage = .loadingOTP
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.sendCode()
        }
    }
    
    private func sendCode() {
        Task {
            do {
                try await authService.askResetCode(email: model.emailForReset)
                
                await MainActor.run {
                    self.resetPasswordStage = .enterCode(.inProgress(index: 0))
                    self.resetCode = ""
                    self.timerStart()
                }
                
            } catch let error as AuthServiceError {
                await MainActor.run {
                    self.resetPasswordStage = .gettingEmail
                    self.resetPasswordError = error
                }
            }
        }

    }
    
    func validatePasswords(password: String, passwordWith: String) -> [IAuthValidationError] {
        (validator.checkPassword(password: password, type: .password) + validator.checkPassword(password: passwordWith, type: .confirmPassword) + validator.checkPasswordsMatch(password: password, confirmPassword: passwordWith))
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
        
        if validationErrors.isEmpty {
            Task {
                do {
                    try await authService.login(model: model)
                    await MainActor.run {
                        onAuthSuccess()
                    }
                } catch let error {
                    await MainActor.run {
                        self.authError = error as? AuthServiceError ?? AuthServiceError.loginError(.unknown(message: "Login error occured"))
                    }
                }
            }
        }
        
    }
    
    private func register() {
        validateRegister()
        
        if !isAgree {
            isAgreeError = true
            return
        } else {
            isAgreeError = false
        }
        
        if validationErrors.isEmpty {
            Task {
                do {
                    try await authService.register(model: model)
                    await MainActor.run {
                        onAuthSuccess()
                    }
                } catch let error {
                    await MainActor.run {
                        self.authError = error as? AuthServiceError ?? AuthServiceError.registerError(.unknown(message: "Register error occured"))
                    }
                }
            }
        }
    }
    
}

extension AuthViewModel {
    
    enum ResetPasswordStage: Equatable {
        case gettingEmail
        case loadingOTP
        case enterCode(EnterCodeState)
        case enterNewPassword
        case success
        
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
