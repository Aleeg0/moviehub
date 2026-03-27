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
    
    var body: some View {
        
        //TabbarView(viewModel: .init())
        let authService = AuthService(networkManager: networkManager, decoder: decoder, privateStorage: privateStorage)
        AuthView(viewModel: .init(authService: authService, validator: AuthValidator()))
    
    }
}
