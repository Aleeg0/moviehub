//
//  ProfileFlowView.swift
//  moviehub-iOS
//
//  Created by Pavel Playerz0redd on 24.03.26.
//

import Foundation
import SwiftUI

struct ProfileFlowView: View {
    private let onExit: () -> Void
    
    init(onExit: @escaping () -> Void) {
        self.onExit = onExit
    }
    
    var body: some View {
        NavigationStack {
            ProfileView(viewModel: .init(authService: AuthService(networkManager: NetworkManager(), decoder: DecodeManager(), privateStorage: UserDefaultsStorageManager()), profileService: ProfileService(networkManager: NetworkManager(), privateStorage: UserDefaultsStorageManager(), decoder: DecodeManager()), providerService: ProvidersService(networkManager: NetworkManager(), decoder: DecodeManager(), privateManager: UserDefaultsStorageManager()), onExit: onExit))
        }
    }
}
