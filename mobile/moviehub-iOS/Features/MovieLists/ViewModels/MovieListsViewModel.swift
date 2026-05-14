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
    @Published var comment: String = ""
    @Published var rating: Int = 0
    @Published var isShowingRatingView = false
    @Published var selectedMovie: MovieListModel?
    
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
    
    func deleteMovie(movieId: Int) {
        Task {
            try await self.movieListProvider.deleteMovie(movieId: movieId)
        }
        films.removeAll(where: { $0.id == movieId })
    }
    
    func cancelRateShowing() {
        isShowingRatingView = false
        selectedMovie = nil
        comment = ""
        rating = 0
        isShowingRatingView = false
    }
    
    func changeRating(movie: MovieListModel) {
        Task {
            try await self.movieListProvider.changeStatus(newStatus: .viewed, movieId: movie.id, comment: comment.isEmpty ? nil : comment, rating: rating == 0 ? nil : rating)
            await MainActor.run {
                films.removeAll(where: { $0 == movie})
                var movie = movie
                movie.comment = comment.isEmpty ? nil : comment
                movie.rating = rating == 0 ? nil : rating
                movie.status = .viewed
                films.insert(movie, at: 0)
                cancelRateShowing()
            }
        }
    }
    
    func changeStatus(newStatus: FilmsViewModel.SwipeStatus, movie: MovieListModel) {
        selectedMovie = movie
        if newStatus == .viewed {
            isShowingRatingView = true
            return
        }
        Task {
            try await self.movieListProvider.changeStatus(newStatus: newStatus, movieId: movie.id, comment: comment.isEmpty ? nil : comment, rating: rating == 0 ? nil : rating)
        }
        films.removeAll(where: { $0 == movie})
        var movie = movie
        movie.comment = nil
        movie.rating = nil
        movie.status = switch newStatus {
        case .liked:
                .liked
        case .disliked:
                .disliked
        case .viewed:
                .viewed
        }
        films.insert(movie, at: 0)
        cancelRateShowing()
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
