//
//  ProvidersViewModel.swift
//  moviehub-iOS
//
//  Created by Pavel Playerz0redd on 10.05.26.
//

import Foundation
import Combine

final class ProvidersViewModel: ObservableObject {
    
    @Published var allProviders: [ProviderModel] = []
    @Published var selectedProviders: Set<ProviderModel> = []
    @Published var findText: String = ""
    
    private var dismiss: () -> Void
    private let providerService: ProvidersServiceProtocol
    
    var visibleProviders: [ProviderModel] {
        findText.isEmpty ? allProviders : allProviders.filter({ $0.name.lowercased().contains(findText.lowercased()) })
    }
    
    init(providerService: ProvidersServiceProtocol, dismiss: @escaping () -> Void) {
        self.providerService = providerService
        self.dismiss = dismiss
        fetchAllProviders()
    }
    
    func uploadProviders() {
        Task {
            try await providerService.uploadUsersProviders(providers: Array(selectedProviders))
        }
        dismiss()
    }
    
    func fetchAllProviders() {
        Task {
            let providers = try await providerService.fetchAllProviders()
            
            await MainActor.run {
                self.allProviders = providers
            }
        }
    }
    
    func pickProvider(provider: ProviderModel) {
        selectedProviders.insert(provider)
    }
    
    
}
