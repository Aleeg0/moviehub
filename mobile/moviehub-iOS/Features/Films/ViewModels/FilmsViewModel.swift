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
    
    
    private let filmsProvider: IFilmsProvider
    private var page: Int
    
    init(filmsProvider: IFilmsProvider) {
        self.filmsProvider = filmsProvider
        self.page = 79//Int.random(in: 1...100)
        
        fetchGenres()
        fetchFilms()
    }
    
    var visibleFilms: ArraySlice<FilmModel> {
        films.prefix(3)
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
    
    private func fetchGenres() {
        Task {
            let genres = try await filmsProvider.fetchGenres(language: .ru)
            await MainActor.run {
                self.genres = Dictionary(uniqueKeysWithValues: genres.map({ ($0.id, $0.name.capitalized) }))
            }
        }
    }
    
    func onSwipe() {
        self.films.removeFirst()
        self.fetchFilms()
    }
    
    func fetchFilms() {
        guard self.films.count < 5 else { return }

        let params: FilmsEndpoints.DiscoverMoviesParams = .init(language: .ru, page: page, sortBy: .popularity, includeAdult: true, watchRegion: nil, watchProviderIds: nil, genreIds: nil, runtimeGte: nil, runtimeLte: nil)
        Task {
            let films = try await filmsProvider.fetchFilms(params: params)
            filmsProvider.prefetchImages(urls: films.compactMap( {URL(string: $0.image ?? "")} ))
            await MainActor.run {
                self.films += films
                self.page = Int.random(in: 1...100)
            }
        }
    }
    
    func handleButton(type: ActionButton) {
        films.removeFirst()
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
