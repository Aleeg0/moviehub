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
        VStack {
            headerView
            
            inputSection
        }
        .offset(y: isFocused ? -30 : 0)
        .ignoresSafeArea(edges: .bottom)
        .padding(.horizontal, 20)
        .animation(.bouncy, value: viewModel.authType)
    }
}

private extension AuthView {
    var inputSection: some View {
        VStack(spacing: 10) {
            
            authTypePicker
            
            if viewModel.authType == .register {
                textField(text: $viewModel.model.name, field: .name)
                    .transition(.scale.combined(with: .opacity))
            }
            
            textField(text: $viewModel.model.email, field: .email)
            
            textField(text: $viewModel.model.password, field: .password)
            
            if viewModel.authType == .register {
                textField(text: $viewModel.model.confirmPassword, field: .confirmPassword)
                    .transition(.scale.combined(with: .opacity))
            }
            
            actionButton
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
    
    var actionButton: some View {
        Button(action: viewModel.onAuth) {
            Text(viewModel.authType.actionButtonCaption)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .font(.system(size: 20, weight: .semibold))
                .background(Capsule().foregroundStyle(authGradient))
        }
    }
}

private extension AuthView {
    func textField(text: Binding<String>, field: AuthViewModel.FieldType) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            
            Text(field.caption)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.gray)
            
            if field.isSecured {
                SecureField("", text: text, prompt: Text(field.prompt).font(.system(size: 20, weight: .semibold)))
                    .modifier(AuthTextFieldModifier())
                    .focused($isFocused)
            } else {
                TextField("", text: text, prompt: Text(field.prompt).font(.system(size: 20, weight: .semibold)))
                    .modifier(AuthTextFieldModifier())
            }
            
//            Text("Error: field is empty")
//                .foregroundStyle(.red)
//                .font(.system(size: 15, weight: .semibold))
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
        Button(action: viewModel.changeAuthType) {
            Text(type.actionButtonCaption)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(type == viewModel.authType ? .white : .gray)
                .padding(12)
                .frame(maxWidth: .infinity)
                .background {
                    if type == viewModel.authType {
                        Capsule()
                            .foregroundStyle(authGradient)
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
                    authGradient
                        .clipShape(RoundedRectangle(cornerRadius: 23))
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

private extension AuthView {
    var authGradient: LinearGradient {
        .init(colors: [.authBlueTop, .authBlueDown], startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}
