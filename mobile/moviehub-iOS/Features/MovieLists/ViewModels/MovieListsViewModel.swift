//
//  MovieListsViewModel.swift
//  moviehub-iOS
//
//  Created by Pavel Playerz0redd on 19.04.26.
//

import Foundation
import Combine

@MainActor
final class MovieListsViewModel: ObservableObject {
    
    @Published var selectedTab: Tabs = .liked
    @Published var films: [MovieListModel] = []
    @Published var viewState: ViewState = .loading
    @Published var genres: [Int : String] = [:]
    
    private let movieListProvider: UserListFilmProviderProtocol = UserListFilmProvider(networkManager: NetworkManager(), privateStorage: UserDefaultsStorageManager(), decoder: DecodeManager())
    private let filmsProvider: IFilmsProvider = FilmsProvider(networkManager: NetworkManager(), decoder: DecodeManager())
    
    init() {
        fetchGenres()
    }
    
    func fetchFilms() {
        Task {
            let movies = try await movieListProvider.fetchUserFilms()
            await MainActor.run {
                self.films = movies
            }
        }
        self.viewState = .success
    }
    
    private func fetchGenres() {
        Task {
            let genres = try await filmsProvider.fetchGenres(language: .ru)
            await MainActor.run {
                self.genres = Dictionary(uniqueKeysWithValues: genres.map({ ($0.id, $0.name.capitalized) }))
            }
        }
    }
}


extension MovieListsViewModel {
    enum Tabs: CaseIterable, Hashable {
        case liked
        case disliked
        case watched
        
        var image: String {
            switch self {
            case .liked:
                "heart.circle"
            case .disliked:
                "heart.slash.circle"
            case .watched:
                "eyes.inverse"
            }
        }
        
        var caption: LocalizedStringResource {
            switch self {
            case .liked:
                "Нравится"
            case .disliked:
                "Не нравится"
            case .watched:
                "Смотрел"
            }
        }
    }
}
