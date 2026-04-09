//
//  FilmDescriptionViewModel.swift
//  moviehub-iOS
//
//  Created by Pavel Playerz0redd on 9.04.26.
//

import Foundation
import Combine

final class FilmDetailsViewModel: ObservableObject {
    
    @Published var details: FilmDetailsModel?
    
    private let filmsProvider: IFilmsProvider
    private let filmId: Int
    
    init(filmsProvider: IFilmsProvider, filmId: Int) {
        self.filmsProvider = filmsProvider
        self.filmId = filmId
        fetchDetails()
    }
    
    private func fetchDetails() {
        Task {
            let details = try await filmsProvider.fetchFilmDetails(id: filmId, language: .ru) 
            await MainActor.run {
                self.details = details
            }
        }
    }
    
}
