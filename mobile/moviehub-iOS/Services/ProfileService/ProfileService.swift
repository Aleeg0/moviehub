//
//  ProfileService.swift
//  moviehub-iOS
//
//  Created by Pavel Playerz0redd on 25.04.26.
//

import Foundation

protocol ProfileServiceProtocol {
    func updateStats() async throws -> StatsModel
}

final class ProfileService: ProfileServiceProtocol {
    
    private let networkManager: INetworkManager
    private let privateStorage: IPrivateManager
    private let decoder: IDecodeManager
    
    init(networkManager: INetworkManager, privateStorage: IPrivateManager, decoder: IDecodeManager) {
        self.networkManager = networkManager
        self.privateStorage = privateStorage
        self.decoder = decoder
    }
    
    func updateStats() async throws -> StatsModel {
        guard let accessToken: String = privateStorage.fetch(key: "token") else { return .init() }
        guard let refreshToken: String = privateStorage.fetch(key: "refreshToken") else { return .init() }
        
        let tokenBody: Data? = decoder.encode(data: RefreshTokensDTO(refreshToken: refreshToken))
        
        guard let tokenData = try await networkManager.sendRequest(endpoint: MovieListsEndpoints.refreshTokens, body: tokenBody, authorization: nil) else { return .init() }
        
        guard let newTokens: NewTokensDTO = decoder.decode(data: tokenData) else { return .init() }
        
        privateStorage.store(key: "token", object: newTokens.accessToken)
        privateStorage.store(key: "refreshToken", object: newTokens.refreshToken)
        
        guard let data = try await networkManager.sendRequest(endpoint: ProfileEndpoints.stats, body: nil, authorization: .bearer(token: newTokens.accessToken)) else { return .init() }
        
        if let stats: StatsDTO = decoder.decode(data: data) {
            return .init(from: stats)
        }
        
        return .init()
    }
}
