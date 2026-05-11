//
//  FilmsViewModel.swift
//  moviehub-iOS
//
//  Created by Pavel Playerz0redd on 6.04.26.
//

import Foundation
import Combine

final class FilmsViewModel: ObservableObject {
    
    @Published var films: [FilmModel] = []
    @Published var genres: [Int : String] = [:]
    @Published var isShowingDetails = false
    @Published var selectedFilmId: Int?
    @Published var selectedStarsCount = 0
    @Published var isShowingRateView = false
    @Published var noteString: String = ""
    @Published var userProviders: Set<Int>?
    
    private let filmsProvider: IFilmsProvider
    private let swipeService: SwipeServiceProtocol
    private let providersService: ProvidersServiceProtocol
    
    private var page: Int
    
    init(filmsProvider: IFilmsProvider, swipeService: SwipeServiceProtocol, providerService: ProvidersServiceProtocol) {
        self.filmsProvider = filmsProvider
        self.swipeService = swipeService
        self.providersService = providerService
        self.page = Int.random(in: 1...20)
        
        self.swipeService.connect()
        fetchGenres()
        fetchFilms()
    }
    
    var visibleFilms: ArraySlice<FilmModel> {
        films.prefix(3)
    }
    
    func fetchUsersProviders() {
        Task {
            let providers = try await providersService.fetchUsersProviders()
            await MainActor.run {
                if !providers.isEmpty {
                    self.userProviders = providers
                }
            }
        }
    }
    
    func showDetails(filmId: Int) {
        self.selectedFilmId = filmId
        self.isShowingDetails = true
    }
    
    func filmGenres(film: FilmModel) -> String {
        films
            .first(where: { $0 == film })?
            .genres
            .map({ genres[$0] ?? "No genre" })
            .prefix(2)
            .joined(separator: " / ") ?? ""
    }
    
    func onDismiss() {
        self.isShowingRateView = false
        self.selectedStarsCount = 0
        self.noteString = ""
    }
    
    private func fetchGenres() {
        Task {
            let genres = try await filmsProvider.fetchGenres(language: .ru)
            await MainActor.run {
                self.genres = Dictionary(uniqueKeysWithValues: genres.map({ ($0.id, $0.name.capitalized) }))
            }
        }
    }
    
    func sendViewedMovie() {
        guard let movie = films.first else { return }
        self.swipeService.sendMovieInfo(movie: movie, status: .viewed, rating: selectedStarsCount == 0 ? nil : selectedStarsCount, comment: noteString.isEmpty ? nil : noteString)
        self.films.removeFirst()
        clearRating()
        self.fetchFilms()
        
    }
    
    private func clearRating() {
        noteString = ""
        selectedStarsCount = 0
        isShowingRateView = false
    }
    
    func onSwipe(status: SwipeStatus) {
        guard let movie = films.first else { return }
        if status == .viewed {
            isShowingRateView = true
            return
        }
        self.swipeService.sendMovieInfo(movie: movie, status: status, rating: nil, comment: nil)
        self.films.removeFirst()
        self.fetchFilms()
    }
    
    func fetchFilms() {
        guard self.films.count < 5 else { return }

        let params: FilmsEndpoints.DiscoverMoviesParams = .init(language: .ru, page: page, sortBy: .popularity, includeAdult: true, watchRegion: nil, watchProviderIds: userProviders, genreIds: nil, runtimeGte: nil, runtimeLte: nil)
        Task {
            let films = try await filmsProvider.fetchFilms(params: params)
            filmsProvider.prefetchImages(urls: films.compactMap( {URL(string: $0.image ?? "")} ))
            await MainActor.run {
                self.films += films
                self.page = Int.random(in: 1...20)
            }
        }
    }
    
    func handleButton(type: ActionButton) {
        let status: SwipeStatus = switch type {
        case .dontWant:
                .disliked
        case .watched:
                .viewed
        case .want:
                .liked
        }
        onSwipe(status: status)
    }
    
}

extension FilmsViewModel {
    enum SwipeStatus {
        case liked
        case disliked
        case viewed
    }
}

extension FilmsViewModel {
    enum ActionButton: CaseIterable {
        case dontWant
        case watched
        case want
        
        var title: LocalizedStringResource {
            switch self {
            case .dontWant:
                "Dont want"
            case .want:
                "Want"
            case .watched:
                "Watched"
            }
        }
        
        var icon: String {
            switch self {
            case .dontWant:
                "arrow.left"
            case .want:
                "arrow.right"
            case .watched:
                "arrow.up"
            }
        }
    
    }
}
