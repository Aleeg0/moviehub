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
    
    func saveUserInfo(userModel: UserModel)
    func fetchUserInfo() -> UserModel?
    func removeUserInfo()
}

final class AuthService: IAuthService {
    
    private let networkManager: INetworkManager
    private let decoder: IDecodeManager
    private let privateStorage: IPrivateManager
    
    private let privateStorageTokenKey = "token"
    private let userInfoKey = "userInfo"
    
    init(networkManager: INetworkManager, decoder: IDecodeManager, privateStorage: IPrivateManager) {
        self.networkManager = networkManager
        self.decoder = decoder
        self.privateStorage = privateStorage
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
            guard let result = try await networkManager.sendRequest(endpoint: endpoint, body: body) else { throw NetworkError.unknown(message: "Unknown error occured") }
            
            data = result
        } catch let error {
            throw .loginError(error as? NetworkError ?? .unknown(message: "Unknown error occured"))
        }
        
        if let response: AuthResponseDTO = decoder.decode(data: data) {
            privateStorage.store(key: privateStorageTokenKey, object: response.accessToken)
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
            guard let result = try await networkManager.sendRequest(endpoint: endpoint, body: body) else { throw NetworkError.unknown(message: "Unknown error occured") }
            
            data = result
        } catch let error {
            throw .registerError(error as? NetworkError ?? .unknown(message: "Unknown error occured"))
        }
        
        if let response: AuthResponseDTO = decoder.decode(data: data) {
            privateStorage.store(key: privateStorageTokenKey, object: response.accessToken)
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
