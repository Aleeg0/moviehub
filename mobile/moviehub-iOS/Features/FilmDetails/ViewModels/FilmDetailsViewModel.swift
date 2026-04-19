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
    @Published var images: ImagesModel?
    @Published var reviews: [ReviewModel] = []
    @Published var viewState: ViewState = .loading
    
    private let filmsProvider: IFilmsProvider
    private let filmId: Int
    private var reviewPage: Int = 1
    
    init(filmsProvider: IFilmsProvider, filmId: Int) {
        self.filmsProvider = filmsProvider
        self.filmId = filmId
        fetchDetails()
        fetchImages()
        fetchReviews()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.viewState = .success
        }
    }
    
    private func fetchReviews() {
        Task {
            let reviews = try await filmsProvider.fetchReviews(id: filmId, page: reviewPage)
            
            await MainActor.run {
                let urls: [URL] = reviews.compactMap( { URL(string: $0.authorDetails.avatarPath ?? "" )} )
                self.filmsProvider.prefetchImages(urls: urls)
                
                self.reviews += reviews
            }
        }
    }
    
    private func fetchImages() {
        Task {
            let images = try await filmsProvider.fetchFilmImages(id: filmId)
            
            await MainActor.run {
                self.images = images
                let urls: [URL] = images.backdrops.compactMap({ URL(string: $0.filePath )}) + images.logos.compactMap({ URL(string: $0.filePath )}) + images.posters.compactMap({ URL(string: $0.filePath )})
                
                self.filmsProvider.prefetchImages(urls: urls)
            }
        }
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
