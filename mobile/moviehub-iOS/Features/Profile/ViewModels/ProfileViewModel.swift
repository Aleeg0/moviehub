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
    
    // MARK: - Init
    init(authService: IAuthService) {
        self.authService = authService
        
        self.userModel = authService.fetchUserInfo()
    }
    
    func signOut() {
        self.authService.signOut()
    }
    
    var nameFirstLetter: String {
        if let name = userModel?.name, let letter = name.first {
            return String(letter)
        }
        return "1"
    }
    
    
}
