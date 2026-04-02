//
//  RootViewModel.swift
//  moviehub-iOS
//
//  Created by Pavel Playerz0redd on 31.03.26.
//

import Foundation
import Combine

final class RootViewModel: ObservableObject {
    @Published var isSigned: Bool
    
    private let authService: IAuthService
    
    init(authService: IAuthService) {
        self.authService = authService
        self.isSigned = authService.isLoggedIn()
    }
    
    func onAuth() {
        self.isSigned = true
    }
    
    func onExit() {
        self.isSigned = false
    }
}
