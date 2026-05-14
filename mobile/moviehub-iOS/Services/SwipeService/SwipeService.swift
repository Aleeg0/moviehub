//
//  SwipeService.swift
//  moviehub-iOS
//
//  Created by Pavel Playerz0redd on 21.04.26.
//

import Foundation

protocol SwipeServiceProtocol {
    func sendMovieInfo(movie: FilmModel, status: FilmsViewModel.SwipeStatus, rating: Int?, comment: String?)
    func connect()
}

final class SwipeService: SwipeServiceProtocol {
    
    private let networkManager: INetworkManager
    private let privateStorage: IPrivateManager
    private let decoder: IDecodeManager
    
    init(dependency: Dependency) {
        self.networkManager = dependency.networkManager
        self.privateStorage = dependency.privateStorage
        self.decoder = dependency.decoder
    }
    
    func sendMovieInfo(movie: FilmModel, status: FilmsViewModel.SwipeStatus, rating: Int? = nil, comment: String? = nil) {
        let dto = SwipeMovieDTO(from: movie, status: status, comment: comment, rating: rating)
        let data = decoder.encode(data: dto)
        
        networkManager.sendWithWebsocket(data: data)
    }
    
    func connect() {
        guard let access: String = self.privateStorage.fetch(key: "token") else { return }
        guard let token: String = self.privateStorage.fetch(key: "refreshToken") else { return }
        print("access : \(access)")
        print("---------")
        
        networkManager.connectWebsocket(
            url: SwipeServiceEndpoints.websocketMovieTracking(refreshToken: token).url
        )
    }
    
}

extension SwipeService {
    struct Dependency {
        let networkManager: INetworkManager
        let privateStorage: IPrivateManager
        let decoder: IDecodeManager
    }
}
