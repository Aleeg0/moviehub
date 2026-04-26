//
//  UserListFilmProvider.swift
//  moviehub-iOS
//
//  Created by Pavel Playerz0redd on 19.04.26.
//

import Foundation
import Kingfisher

protocol UserListFilmProviderProtocol {
    func fetchUserFilms() async throws -> [MovieListModel]
}

final class UserListFilmProvider: UserListFilmProviderProtocol {
    
    private let networkManager: INetworkManager
    private let privateStorage: IPrivateManager
    private let decoder: IDecodeManager
    
    private var prefetcher: ImagePrefetcher?
    
    init(networkManager: INetworkManager, privateStorage: IPrivateManager, decoder: IDecodeManager) {
        self.networkManager = networkManager
        self.privateStorage = privateStorage
        self.decoder = decoder
    }

    func fetchUserFilms() async throws -> [MovieListModel] {
        
        guard let accessToken: String = privateStorage.fetch(key: "token") else { return [] }
        guard let refreshToken: String = privateStorage.fetch(key: "refreshToken") else { return [] }
        
        let tokenBody: Data? = decoder.encode(data: RefreshTokensDTO(refreshToken: refreshToken))
        
        guard let tokenData = try await networkManager.sendRequest(endpoint: MovieListsEndpoints.refreshTokens, body: tokenBody, authorization: nil) else { return [] }
        
        guard let newTokens: NewTokensDTO = decoder.decode(data: tokenData) else { return [] }
        
        privateStorage.store(key: "token", object: newTokens.accessToken)
        privateStorage.store(key: "refreshToken", object: newTokens.refreshToken)
        
        
        guard let data = try await networkManager.sendRequest(endpoint: MovieListsEndpoints.allMovies, body: nil, authorization: .bearer(token: newTokens.accessToken)) else { return [] }
        
        if let movies: MoviesListDTO = decoder.decode(data: data) {
            let urls: [URL] = movies.movies.compactMap( { URL(string: $0.posterPath ?? "") } )
            prefetchImages(urls: urls)
            return movies.movies.map( { MovieListModel(from: $0) } )
        } else {
            return []
        }
    }
    
    private func prefetchImages(urls: [URL]) {
        self.prefetcher?.stop()
        let prefetcher = ImagePrefetcher(urls: urls)
        prefetcher.start()
        self.prefetcher = prefetcher
    }
}
