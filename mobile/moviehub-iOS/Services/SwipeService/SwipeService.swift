//
//  SwipeService.swift
//  moviehub-iOS
//
//  Created by Pavel Playerz0redd on 21.04.26.
//

import Foundation

protocol SwipeServiceProtocol {
    func sendMovieInfo(movie: FilmModel, status: FilmsViewModel.SwipeStatus)
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
    
    func sendMovieInfo(movie: FilmModel, status: FilmsViewModel.SwipeStatus) {
        let dto = SwipeMovieDTO(from: movie, status: status)
        let data = decoder.encode(data: dto)
        
        networkManager.sendWithWebsocket(data: data)
    }
    
    func connect() {
        guard let token: String = self.privateStorage.fetch(key: "refreshToken") else { return }
        
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
