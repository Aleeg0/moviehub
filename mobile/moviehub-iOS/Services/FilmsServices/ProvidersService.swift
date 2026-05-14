//
//  ProvidersService.swift
//  moviehub-iOS
//
//  Created by Pavel Playerz0redd on 10.05.26.
//

import Foundation
import Kingfisher

protocol ProvidersServiceProtocol {
    func fetchAllProviders() async throws -> [ProviderModel]
    func fetchUsersProviders() async throws -> Set<Int>
    func uploadUsersProviders(providers: [ProviderModel]) async throws
}

final class ProvidersService: ProvidersServiceProtocol {
    
    private let networkManager: INetworkManager
    private let decoder: IDecodeManager
    private let privateManager: IPrivateManager
    private var prefetcher: ImagePrefetcher?
    
    init(networkManager: INetworkManager, decoder: IDecodeManager, privateManager: IPrivateManager) {
        self.networkManager = networkManager
        self.decoder = decoder
        self.privateManager = privateManager
    }
    
    func fetchUsersProviders() async throws -> Set<Int> {
        do {
            guard let token: String = privateManager.fetch(key: "token") else { throw NSError() }
            
            let newToken = try await getNewAccess()
            
            guard let data = try await networkManager.sendRequest(endpoint: ProviderEndpoints.fetchProviders, body: nil, authorization: .bearer(token: newToken)) else { return [] }
            
            guard let dto: ProvidersRequestDTO = decoder.decode(data: data) else { return [] }
            return dto.movieIds
        }
    }
    
    private func getNewAccess() async throws -> String {
        guard let accessToken: String = privateManager.fetch(key: "token") else { return "" }
        guard let refreshToken: String = privateManager.fetch(key: "refreshToken") else { return "" }
        
        let tokenBody: Data? = decoder.encode(data: RefreshTokensDTO(refreshToken: refreshToken))
        
        guard let tokenData = try await networkManager.sendRequest(endpoint: MovieListsEndpoints.refreshTokens, body: tokenBody, authorization: nil) else { return "" }
        
        guard let newTokens: NewTokensDTO = decoder.decode(data: tokenData) else { return "" }
        
        privateManager.store(key: "token", object: newTokens.accessToken)
        privateManager.store(key: "refreshToken", object: newTokens.refreshToken)
        return newTokens.accessToken
    }
    
    func uploadUsersProviders(providers: [ProviderModel]) async throws {
        do {
            guard let token: String = privateManager.fetch(key: "token") else { throw NSError() }
            
            let newToken = try await getNewAccess()
            
            let dto: ProvidersRequestDTO = .init(movieIds: Set(providers.map({ $0.id} )))
            let body = decoder.encode(data: dto)
            
            try await networkManager.sendRequest(endpoint: ProviderEndpoints.uploadProviders, body: body, authorization: .bearer(token: newToken))
        }
    }
    
    func fetchAllProviders() async throws -> [ProviderModel] {
        do {
            guard let data = try await networkManager.sendRequest(endpoint: ProviderEndpoints.providers, body: nil, authorization: .bearer(token: ProviderEndpoints.TOKEN)) else { return [] }
            
            guard let response: ProvidersResponse = decoder.decode(data: data) else { return [] }
            
            let models: [ProviderModel] = response.results.map({ .init(from: $0) })
            let urls = models.compactMap( { URL(string: $0.logoPath ) } )
            prefetchImages(urls: urls)
            return models
        } catch let error {
            throw error
        }
    }
    
    private func prefetchImages(urls: [URL]) {
        self.prefetcher?.stop()
        let prefetcher = ImagePrefetcher(urls: urls)
        prefetcher.start()
        self.prefetcher = prefetcher
    }
}
