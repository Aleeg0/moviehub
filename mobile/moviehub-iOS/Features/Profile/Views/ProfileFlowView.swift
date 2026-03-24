//
//  ProfileFlowView.swift
//  moviehub-iOS
//
//  Created by Pavel Playerz0redd on 24.03.26.
//

import Foundation
import SwiftUI

struct ProfileFlowView: View {
    var body: some View {
        NavigationStack {
            ProfileView(viewModel: .init(authService: AuthService(networkManager: NetworkManager(), decoder: DecodeManager(), privateStorage: UserDefaultsStorageManager())))
        }
    }
}
