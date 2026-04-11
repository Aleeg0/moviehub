//
//  moviehub_iOSApp.swift
//  moviehub-iOS
//
//  Created by Pavel Playerz0redd on 12.03.26.
//

import SwiftUI

@main
struct moviehub_iOSApp: App {
    private let authService: IAuthService = AuthService(networkManager: NetworkManager(), decoder: DecodeManager(), privateStorage: UserDefaultsStorageManager())
    var body: some Scene {
        WindowGroup {
            //FilmStackView()
            RootView(viewModel: .init(authService: authService))
        }
    }
}
