//
//  ProfileViewModel.swift
//  moviehub-iOS
//
//  Created by Pavel Playerz0redd on 24.03.26.
//

import Foundation
import Combine

@MainActor
final class ProfileViewModel: ObservableObject {
    
    // MARK: - Rx properties
    @Published var userModel: UserModel?
    @Published var stats: StatsModel = .init()
    
    // MARK: - Services
    private let authService: IAuthService
    private let onExit: () -> Void
    private let profileService: ProfileServiceProtocol
    
    // MARK: - Init
    init(authService: IAuthService, profileService: ProfileServiceProtocol, onExit: @escaping () -> Void) {
        self.authService = authService
        self.profileService = profileService
        self.onExit = onExit
        
        self.userModel = authService.fetchUserInfo()
    }
    
    func updateStats() {
        Task {
            self.stats = try await profileService.updateStats()
        }
    }
    
    func signOut() {
        self.authService.signOut()
        self.onExit()
    }
    
    var nameFirstLetter: String {
        if let name = userModel?.name, let letter = name.first {
            return String(letter)
        }
        return "1"
    }
    
    
}
