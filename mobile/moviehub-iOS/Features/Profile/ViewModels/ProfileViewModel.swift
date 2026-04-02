//
//  ProfileViewModel.swift
//  moviehub-iOS
//
//  Created by Pavel Playerz0redd on 24.03.26.
//

import Foundation
import Combine

final class ProfileViewModel: ObservableObject {
    
    // MARK: - Rx properties
    @Published var userModel: UserModel?
    
    // MARK: - Services
    private let authService: IAuthService
    private let onExit: () -> Void
    
    // MARK: - Init
    init(authService: IAuthService, onExit: @escaping () -> Void) {
        self.authService = authService
        self.onExit = onExit
        
        self.userModel = authService.fetchUserInfo()
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
