//
//  AuthService.swift
//  moviehub-iOS
//
//  Created by Pavel Playerz0redd on 19.03.26.
//

import Foundation

protocol IAuthService {
    func login(model: AuthModel) async throws(AuthServiceError)
    func register(model: AuthModel) async throws(AuthServiceError)
    func signOut()
    func isLoggedIn() -> Bool
    func askResetCode(email: String) async throws(AuthServiceError)
    func verifyCode(email: String, code: String) async throws(AuthServiceError) -> String
    func resetPassword(email: String, password: String) async throws(AuthServiceError)
    
    func saveUserInfo(userModel: UserModel)
    func fetchUserInfo() -> UserModel?
    func removeUserInfo()
    func getNewAccess() async throws
}

final class AuthService: IAuthService {
    
    private let networkManager: INetworkManager
    private let decoder: IDecodeManager
    private let privateStorage: IPrivateManager
    
    private let privateStorageTokenKey = "token"
    private let resetTokenKey = "resetToken"
    private let userInfoKey = "userInfo"
    private let refreshTokenKey = "refreshToken"
    
    init(networkManager: INetworkManager, decoder: IDecodeManager, privateStorage: IPrivateManager) {
        self.networkManager = networkManager
        self.decoder = decoder
        self.privateStorage = privateStorage
    }
    
    func getNewAccess() async throws {
        guard let accessToken: String = privateStorage.fetch(key: "token") else { return }
        guard let refreshToken: String = privateStorage.fetch(key: "refreshToken") else { return }
        
        let tokenBody: Data? = decoder.encode(data: RefreshTokensDTO(refreshToken: refreshToken))
        
        guard let tokenData = try await networkManager.sendRequest(endpoint: MovieListsEndpoints.refreshTokens, body: tokenBody, authorization: nil) else { return }
        
        guard let newTokens: NewTokensDTO = decoder.decode(data: tokenData) else { return }
        
        privateStorage.store(key: "token", object: newTokens.accessToken)
        privateStorage.store(key: "refreshToken", object: newTokens.refreshToken)
    }
    
    
    
    func resetPassword(email: String, password: String) async throws(AuthServiceError) {
        
        let resetCodeDto: ResetCodeDTO = .init(
            resetToken: privateStorage.fetch(key: resetTokenKey) ?? "",
            email: email,
            newPassword: password
        )
        
        let body: Data? = decoder.encode(data: resetCodeDto)
        
        do {
           try await networkManager.sendRequest(endpoint: AuthEndpoints.resetPassword, body: body, authorization: nil)
        } catch let error {
            throw .resetPasswordError(error)
        }
        
    }
    
    func verifyCode(email: String, code: String) async throws(AuthServiceError) -> String {
        
        let verifyDTO: VerifyCodeDTO = .init(email: email, code: code)
        let body: Data? = decoder.encode(data: verifyDTO)
        
        do {
            guard let data = try await networkManager.sendRequest(endpoint: AuthEndpoints.verifyCode, body: body, authorization: nil) else { throw NetworkError.unknown(message: "Unknown") }
            
            guard let response: VerifyCodeResponseDTO = decoder.decode(data: data) else { throw NSError() }
            
            privateStorage.store(key: resetTokenKey, object: response.resetToken)
            
            return response.resetToken
            
        } catch let error as NetworkError {
            throw .loginError(error)
        } catch let error {
            throw .unknown
        }
    }
    
    func askResetCode(email: String) async throws(AuthServiceError) {
        
        let resetDTO = AskResetDTO(email: email)
        let body: Data? = decoder.encode(data: resetDTO)
        
        do {
            try await networkManager.sendRequest(endpoint: AuthEndpoints.askResetCode, body: body, authorization: nil)
        } catch let error {
            throw .resetPasswordError(error)
        }
    }
    
    func saveUserInfo(userModel: UserModel) {
        privateStorage.store(key: userInfoKey, object: userModel)
    }
    
    func fetchUserInfo() -> UserModel? {
        privateStorage.fetch(key: userInfoKey)
    }
    
    func removeUserInfo() {
        privateStorage.remove(key: userInfoKey)
    }
    
    func isLoggedIn() -> Bool {
        if let _: String = self.privateStorage.fetch(key: privateStorageTokenKey) {
            return true
        }
        return false
    }
    
    func login(model: AuthModel) async throws(AuthServiceError) {
        
        let loginRequestDTO: LoginRequestDTO = .init(email: model.email, password: model.password)
        let body: Data? = decoder.encode(data: loginRequestDTO)
        let endpoint: AuthEndpoints = .login
        
        let data: Data
        
        do {
            guard let result = try await networkManager.sendRequest(endpoint: endpoint, body: body, authorization: nil) else { throw NetworkError.unknown(message: "Unknown error occured") }
            
            data = result
        } catch let error {
            throw .loginError(error as? NetworkError ?? .unknown(message: "Unknown error occured"))
        }
        
        if let response: AuthResponseDTO = decoder.decode(data: data) {
            privateStorage.store(key: privateStorageTokenKey, object: response.accessToken)
            privateStorage.store(key: refreshTokenKey, object: response.refreshToken)
            privateStorage.store(key: "name", object: response.name)
            privateStorage.store(key: "email", object: response.email)
        }
        else if let error: ErrorAuthResponseDTO = decoder.decode(data: data) {
            throw .loginError(.unknown(message: "\(error.detail.first?.msg ?? "Error")"))
        }
        else {
            throw .loginError(.unknown(message: "Unknown error occured"))
        }
    }
    
    func register(model: AuthModel) async throws(AuthServiceError) {
        let registerRequestDTO: RegisterRequestDTO = .init(email: model.email, password: model.password, name: model.name)
        let body: Data? = decoder.encode(data: registerRequestDTO)
        let endpoint: AuthEndpoints = .register
        
        let data: Data
        
        do {
            guard let result = try await networkManager.sendRequest(endpoint: endpoint, body: body, authorization: nil) else { throw NetworkError.unknown(message: "Unknown error occured") }
            
            data = result
        } catch let error {
            throw .registerError(error as? NetworkError ?? .unknown(message: "Unknown error occured"))
        }
        
        if let response: AuthResponseDTO = decoder.decode(data: data) {
            privateStorage.store(key: privateStorageTokenKey, object: response.accessToken)
            privateStorage.store(key: refreshTokenKey, object: response.refreshToken)
            privateStorage.store(key: "name", object: model.name)
            privateStorage.store(key: "email", object: model.email)
        }
        else if let error: ErrorAuthResponseDTO = decoder.decode(data: data) {
            throw .registerError(.unknown(message: "\(error.detail.first?.msg ?? "Error")"))
        }
        else {
            throw .registerError(.unknown(message: "Unknown error occured"))
        }
    }
    
    func signOut() {
        privateStorage.remove(key: privateStorageTokenKey)
    }
    
}
