//
//  ContentView.swift
//  moviehub-iOS
//
//  Created by Pavel Playerz0redd on 12.03.26.
//

import SwiftUI

struct RootView: View {
    var body: some View {
        AuthView(viewModel: .init(authService: AuthService(networkManager: NetworkManager(), decoder: DecodeManager(), privateStorage: UserDefaultsStorageManager()), validator: AuthValidator()))
    }
}
