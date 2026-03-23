//
//  AuthService.swift
//  moviehub-iOS
//
//  Created by Pavel Playerz0redd on 19.03.26.
//

import Foundation

protocol IAuthService {
    func login(model: LoginDto) async throws
    func register(model: RegisterDto) async throws
    func signOut()
    func isLoggedIn() -> Bool
}

final class AuthService: IAuthService {
    
    private let networkManager: INetworkManager
    private let decoder: IDecodeManager
    private let privateStorage: IPrivateManager
    
    private let privateStorageTokenKey = "token"
    
    init(networkManager: INetworkManager, decoder: IDecodeManager, privateStorage: IPrivateManager) {
        self.networkManager = networkManager
        self.decoder = decoder
        self.privateStorage = privateStorage
    }
    
    func isLoggedIn() -> Bool {
        if let _: String = self.privateStorage.fetch(key: privateStorageTokenKey) {
            return true
        }
        return false
    }
    
    func login(model: LoginDto) async throws {
        let body: Data? = decoder.encode(data: model)
        
        guard let data = try await networkManager.sendRequest(type: .post, url: "path", body: body) else { throw NSError() }
        
        let token: String = decoder.decode(data: data)
        
        privateStorage.store(key: privateStorageTokenKey, object: token)
        
    }
    
    func register(model: RegisterDto) async throws {
        let body: Data? = decoder.encode(data: model)
        
        guard let data = try await networkManager.sendRequest(type: .post, url: "path", body: body) else { throw NSError() }
        
        let token: String = decoder.decode(data: data)
        
        privateStorage.store(key: privateStorageTokenKey, object: token)
    }
    
    func signOut() {
        privateStorage.remove(key: privateStorageTokenKey)
    }
    
}
