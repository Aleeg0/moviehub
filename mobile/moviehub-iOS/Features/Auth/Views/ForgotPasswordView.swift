//
//  ForgotPasswordView.swift
//  moviehub-iOS
//
//  Created by Pavel Playerz0redd on 21.03.26.
//

import Foundation
import SwiftUI

struct ForgotPasswordView: View {
    @ObservedObject private var viewModel: AuthViewModel
    @FocusState private var isFocused: Bool
    
    init(viewModel: AuthViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ZStack {
            switch viewModel.resetPasswordStage {
            case .gettingEmail:
                gettingEmailView
            case .loadingOTP:
                loadingOTPView
            case .enterCode:
                enterCodeView
            case.enterNewPassword:
                enterNewPasswordView
            case .success:
                successView
            }
        }
        .frame(maxWidth: .infinity)
        .animation(.bouncy, value: viewModel.resetPasswordStage)
        .padding(30)
        .background(
            RoundedRectangle(cornerRadius: 32)
                .fill(.pickerGray)
                .stroke(.authBlueTop, lineWidth: 1)
        )
        .padding(.bottom, 15)
    }
}

private extension ForgotPasswordView {
    
    var successView: some View {
        VStack(spacing: 25) {
            Text("You have changed password successfully")
                .font(.system(size: 24, weight: .semibold))
                .multilineTextAlignment(.center)
            
            Image(systemName: "checkmark.circle")
                .resizable()
                .frame(width: 80, height: 80)
                .foregroundStyle(.authBlueTop)
            
            AuthActionButton(caption: "Continue", style: .authGradient, action: viewModel.onResetPasswordEnd)
        }
    }
}

private extension ForgotPasswordView {
    
    var enterNewPasswordView: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Password")
                .font(.system(size: 26, weight: .medium))
            
            Text("Enter new password")
                .font(.system(size: 18, weight: .medium))
            
            VStack(spacing: 15) {
                
                textField(inputType: .password, errors: viewModel.resetPasswordValidationError as! [AuthValidationError]) {
                    SecureField("", text: $viewModel.newPassword, prompt: Text("Enter Your New Password").font(.system(size: 20, weight: .semibold)))
                        .keyboardType(.default)
                }
                
                textField(inputType: .confirmPassword, errors: viewModel.resetPasswordValidationError as! [AuthValidationError]) {
                    SecureField("", text: $viewModel.confirmNewPassword, prompt: Text("Confirm Your New Password").font(.system(size: 20, weight: .semibold)))
                        .keyboardType(.default)
                }
                
                if let error = viewModel.resetPasswordError {
                    Text(error.description)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.red)
                }
            }
            .animation(.bouncy, value: viewModel.resetPasswordError)
            .animation(.bouncy, value: viewModel.resetPasswordValidationError as! [AuthValidationError])
            
            AuthActionButton(caption: "Change password", style: .authGradient, action: viewModel.resetPassword)
            
        }
    }
}

private extension ForgotPasswordView {
    var enterCodeView: some View {
        VStack(alignment: .leading, spacing: 15) {
            
            Text("Verification")
                .font(.system(size: 26, weight: .medium))
            
            Text("Enter the 5-digit code.")
                .font(.system(size: 18, weight: .medium))
            
            TextField("", text: $viewModel.resetCode)
                .frame(height: 55)
                .keyboardType(.numberPad)
                .opacity(0)
                .focused($isFocused)
                .frame(maxWidth: .infinity)
                .overlay {
                    inputFieldView
                }
                .onChange(of: viewModel.resetCode) { oldValue, newValue in
                    if newValue.count > 5 {
                        viewModel.resetCode = oldValue
                    }
                }
            
            resendCodeButton
        }
        .animation(.bouncy, value: viewModel.resetPasswordStage)
        .onAppear {
            self.isFocused = true
        }
    }
    
    var resendCodeButton: some View {
        Button(action: viewModel.resendCode) {
            Text("Resend Code \(viewModel.getRemainingTime)")
                .foregroundStyle(viewModel.remainingTime > 0 ? .gray : .authBlueTop)
                .font(.system(size: 15, weight: .semibold))
                .disabled(viewModel.remainingTime > 0)
        }
    }
    
    var inputFieldView: some View {
        HStack(spacing: 17) {
            ForEach(0..<5) { index in
                digitView(index: index)
            }
        }
        .keyframeAnimator(initialValue: 0, trigger: viewModel.resetPasswordStage) { content, value in
            content
                .offset(x: value)
        } keyframes: { value in
            KeyframeTrack {
                if case .enterCode(let stage) = viewModel.resetPasswordStage, stage == .error {
                    CubicKeyframe(-10, duration: 0.1)
                    CubicKeyframe(10, duration: 0.1)
                    CubicKeyframe(-5, duration: 0.1)
                    CubicKeyframe(5, duration: 0.1)
                    CubicKeyframe(0, duration: 0.1)
                } else {
                    MoveKeyframe(0)
                }
            }
        }

    }
    
    func digitView(index: Int) -> some View {
        RoundedRectangle(cornerRadius: 14)
            .stroke(getDigitStrokeColor(resetState: viewModel.resetPasswordStage, currentIndex: index), lineWidth: 2)
            .frame(width: 55, height: 55)
            .foregroundStyle(.inputSectionGray)
            .overlay {
                if let digit = viewModel.getDigitByIndex(index: index) {
                    Text(digit)
                        .font(.system(size: 23, weight: .semibold))
                        .transition(.move(edge: .bottom).combined(with: .opacity).combined(with: .scale))
                }
            }
    }
    
    func getDigitStrokeColor(resetState: AuthViewModel.ResetPasswordStage, currentIndex: Int) -> Color {
        if case .enterCode(let resetState) = resetState {
            switch resetState {
            case .error:
                return .red
            case .success:
                return .green
            case .inProgress(let index):
                if index == currentIndex - 1 {
                    return .authBlueTop
                } else {
                    return .black
                }
            }
        } else {
            return .black
        }
    }
}

private extension ForgotPasswordView {
    var gettingEmailView: some View {
        VStack(alignment: .leading, spacing: 25) {
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Reset password")
                    .font(.system(size: 26, weight: .medium))
                
                Text("Enter your email.")
                    .font(.system(size: 18, weight: .medium))
            }
            
            VStack(spacing: 10) {
                
                textField(inputType: .email, errors: viewModel.emailForResetError == nil ? [] : [viewModel.emailForResetError!]) {
                    TextField("", text: $viewModel.model.emailForReset, prompt: Text(FieldType.email.prompt).font(.system(size: 20, weight: .semibold)))
                        .keyboardType(.emailAddress)
                }
                .animation(.bouncy, value: viewModel.emailForResetError)
                
                if let error = viewModel.resetPasswordError {
                    Text(error.description)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.red)
                        .transition(.opacity.combined(with: .scale))
                }
            }
                
            AuthActionButton(caption: "Send code", style: .authGradient) {
                viewModel.onOTPSend()
                if viewModel.emailForResetError == nil {
                    hideKeyboard()
                }
            }
        }
    }
}

private extension ForgotPasswordView {
    
    func textField<Content: View>(inputType: FieldType, errors: [AuthValidationError], content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            content()
                .modifier(AuthTextFieldModifier(error: errors.first))
            
            if let specificError = errors.first(where: {
                if case let .passwordError(_, type) = $0 { return type == inputType }
                return false
            }) {
                if case let .passwordError(passwordError, _) = specificError {
                    Text(passwordError.description)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.red)
                        .transition(.opacity.combined(with: .scale))
                }
            }
            
            if case let .emailError(emailError) = errors.first {
                Text(emailError.description)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.red)
                    .transition(.opacity.combined(with: .scale))
            }
        }
    }
}

private extension ForgotPasswordView {
    var loadingOTPView: some View {
        VStack(spacing: 12) {
            PhaseAnimator(LoadingStages.allCases) { stage in
                Image(systemName: stage.symbol)
                    .font(.system(size: 100))
                    .contentTransition(.symbolEffect)
                    .frame(width: 150, height: 150)
            } animation: { _ in
                    .linear(duration: 0.8)
            }
            .frame(height: 150)
            
            Text("Sending Verification Code")
                .font(.title3)
                .fontWeight(.semibold)
        }
    }
    
    enum LoadingStages: CaseIterable {
        case iphone
        case bubble
        case plane
        
        var symbol: String {
            switch self {
            case .iphone:
                "iphone"
            case .bubble:
                "ellipsis.message.fill"
            case .plane:
                "paperplane.fill"
            }
        }
    }
}

