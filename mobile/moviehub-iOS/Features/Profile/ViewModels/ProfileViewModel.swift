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
    @Published var isShowingProviderPicker = false
    @Published var userProviders: Set<Int> = []
    @Published var profileInfo: ProfileInfoModel
    
    // MARK: - Services
    private let authService: IAuthService
    private let onExit: () -> Void
    private let profileService: ProfileServiceProtocol
    private let providerService: ProvidersServiceProtocol
    
    // MARK: - Init
    init(authService: IAuthService, profileService: ProfileServiceProtocol, providerService: ProvidersServiceProtocol, onExit: @escaping () -> Void) {
        self.authService = authService
        self.profileService = profileService
        self.providerService = providerService
        self.onExit = onExit
        self.profileInfo = profileService.getProfileInfo()
        fetchUsersProviders()
        
        self.userModel = authService.fetchUserInfo()
    }
    
    func cancelShowingProviderPicker() {
        isShowingProviderPicker = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.fetchUsersProviders()
        }
    }
    
    func fetchUsersProviders() {
        Task {
            let providers = try await providerService.fetchUsersProviders()
            await MainActor.run {
                self.userProviders = providers
            }
        }
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
        if let name = profileInfo.name, let letter = name.first {
            return String(letter)
        }
        return "P"
    }
    
    
}
