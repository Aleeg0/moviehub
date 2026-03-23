//
//  AuthView.swift
//  moviehub-iOS
//
//  Created by Pavel Playerz0redd on 20.03.26.
//

import Foundation
import SwiftUI

struct AuthView: View {
    
    @ObservedObject private var viewModel: AuthViewModel
    @Namespace private var namespace
    @FocusState private var isFocused: Bool
    
    init(viewModel: AuthViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ZStack {
            authView
                .disabled(viewModel.isResetingPassword)
                .overlay {
                    Color.black
                        .opacity(viewModel.isResetingPassword ? 0.5 : 0)
                        .ignoresSafeArea()
                }
                .onTapGesture {
                    if viewModel.isResetingPassword {
                        hideKeyboard()
                        viewModel.isResetingPassword = false
                        viewModel.resetCode.removeAll()
                        viewModel.resetPasswordStage = .gettingEmail
                    }
                }
                .scaleEffect(viewModel.isResetingPassword ? 0.92 : 1)
            
            if viewModel.isResetingPassword {
                VStack {
                    ForgotPasswordView(viewModel: viewModel)
                        .padding(10)
                }
                .offset(y: viewModel.offset)
                .scaleEffect(1 - viewModel.offset / 800)
                .frame(maxHeight: .infinity, alignment: .bottom)
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .gesture(
                    DragGesture()
                        .onChanged({ value in
                            let transition = value.translation.height / 7
                            if abs(transition) < 30 {
                                viewModel.offset = transition
                            }
                        })
                        .onEnded({ _ in
                            viewModel.offset = .zero
                        })
                )
                .shadow(radius: 15)
            }
        }
        .animation(.bouncy, value: viewModel.offset)
        .frame(maxHeight: .infinity)
        .animation(.easeInOut, value: viewModel.isResetingPassword)
        .animation(.bouncy, value: viewModel.authType)
    }
}

private extension AuthView {
    var authView: some View {
        VStack {
            headerView
            
            inputSection
        }
        .offset(y: isFocused ? -30 : 0)
        .ignoresSafeArea(edges: .bottom)
        .padding(.horizontal, 20)
        .animation(.bouncy, value: viewModel.validationErrors)
    }
}

private extension AuthView {
    var inputSection: some View {
        VStack(spacing: 10) {
            
            authTypePicker
            
            if viewModel.authType == .register {
                textField(text: $viewModel.model.name, field: .name)
                    .transition(.scale.combined(with: .opacity))
                    .textContentType(.name)
            }
            
            textField(text: $viewModel.model.email, field: .email)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
            
            textField(text: $viewModel.model.password, field: .password)
            
            if viewModel.authType == .register {
                textField(text: $viewModel.model.confirmPassword, field: .confirmPassword)
                    .transition(.scale.combined(with: .opacity))
            }
            
            if viewModel.authType == .login {
                forgotPasswordButton
            }
            
            AuthActionButton(caption: viewModel.authType.actionButtonCaption) {
                hideKeyboard()
                viewModel.onAuth()
            }
            .padding(.top, 5)
            
        }
        .padding(20)
        .background {
            RoundedRectangle(cornerRadius: 26)
                .fill(.inputSectionGray)
                .overlay(
                    RoundedRectangle(cornerRadius: 26)
                        .stroke(Color.blue, lineWidth: 1)
                )
        }
    }
    
    var forgotPasswordButton: some View {
        Button {
            hideKeyboard()
            viewModel.forgotPassword()
        } label: {
            Text("Forgot Password?")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.authGradient)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .transition(.opacity.combined(with: .scale))
                .padding(.vertical, 4)
        }
    }
    
}

private extension AuthView {
    func textField(text: Binding<String>, field: FieldType) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            
            Text(field.caption)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.gray)
            
            if field.isSecured {
                SecureField("", text: text, prompt: Text(field.prompt).font(.system(size: 20, weight: .semibold)))
                    .modifier(AuthTextFieldModifier(error: viewModel.hasError(field: field)))
                    .focused($isFocused)
                    .textContentType(viewModel.authType == .login ? .password : .newPassword)
            } else {
                TextField("", text: text, prompt: Text(field.prompt).font(.system(size: 20, weight: .semibold)))
                    .modifier(AuthTextFieldModifier(error: viewModel.hasError(field: field)))
            }
            
            if let error = viewModel.hasError(field: field) {
                Text(error.description)
                    .foregroundStyle(.red)
                    .font(.system(size: 14))
                    .transition(.opacity.combined(with: .scale))
            }
        }
    }
}

private extension AuthView {
    var authTypePicker: some View {
        
        HStack(spacing: 0) {
            pickerButton(for: .login)
            pickerButton(for: .register)
        }
        .padding(4)
        .background(Capsule().foregroundStyle(.pickerGray))
        
    }
    
    func pickerButton(for type: AuthViewModel.AuthType) -> some View {
        Button {
            hideKeyboard()
            viewModel.changeAuthType()
        } label: {
            Text(type.actionButtonCaption)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(type == viewModel.authType ? .white : .gray)
                .padding(12)
                .frame(maxWidth: .infinity)
                .background {
                    if type == viewModel.authType {
                        Capsule()
                            .foregroundStyle(.authGradient)
                            .matchedGeometryEffect(id: "picker", in: namespace)
                    }
                }
        }

    }
}

private extension AuthView {
    var headerView: some View {
        VStack(spacing: 5) {
            Image(systemName: "film.stack")
                .font(.system(size: 40, weight: .semibold))
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 23)
                        .foregroundStyle(.authGradient)
                )
            
            Text("MovieMatch")
                .font(.system(size: 29, weight: .semibold))
            
            Text("Найдите кино, которое останется в сердце")
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(.gray)
                .multilineTextAlignment(.center)
            
        }
    }
}

