//
//  ContentView.swift
//  moviehub-iOS
//
//  Created by Pavel Playerz0redd on 12.03.26.
//

import SwiftUI

struct RootView: View {
    let networkManager = NetworkManager()
    let decoder = DecodeManager()
    let privateStorage = UserDefaultsStorageManager()
    let authService: IAuthService
    
    @ObservedObject private var viewModel: RootViewModel
    
    init(viewModel: RootViewModel) {
        self.viewModel = viewModel
        self.authService = AuthService(networkManager: networkManager, decoder: decoder, privateStorage: privateStorage)
    }
    
    var body: some View {
        ZStack {
            if viewModel.isSigned {
                TabbarView(viewModel: .init(onExit: viewModel.onExit))
                    .transition(.opacity.combined(with: .scale))
            } else {
                let authService = AuthService(networkManager: networkManager, decoder: decoder, privateStorage: privateStorage)
                AuthView(viewModel: .init(authService: authService, validator: AuthValidator(), onAuthSuccess: viewModel.onAuth))
                    .transition(.opacity.combined(with: .scale))
            }
        }
        .animation(.easeInOut, value: viewModel.isSigned)
    }
}
