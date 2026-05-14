//
//  FilmsProvider.swift
//  moviehub-iOS
//
//  Created by Pavel Playerz0redd on 6.04.26.
//

import Foundation
import Kingfisher

protocol IFilmsProvider {
    func fetchFilms(params: FilmsEndpoints.DiscoverMoviesParams) async throws -> [FilmModel]
    func fetchGenres(language: FilmsEndpoints.DiscoverMoviesParams.DescriptionLanguage) async throws -> [GenreModel]
    func prefetchImages(urls: [URL])
    func fetchFilmDetails(id: Int, language: FilmsEndpoints.DiscoverMoviesParams.DescriptionLanguage) async throws -> FilmDetailsModel
    
    func fetchFilmImages(id: Int) async throws -> ImagesModel
    func fetchReviews(id: Int, page: Int) async throws -> [ReviewModel]
}

final class FilmsProvider: IFilmsProvider {
    private let networkManager: INetworkManager
    private let decoder: IDecodeManager
    private var prefetcher: ImagePrefetcher?
    
    init(networkManager: INetworkManager, decoder: IDecodeManager) {
        self.networkManager = networkManager
        self.decoder = decoder
    }
    
    func prefetchImages(urls: [URL]) {
        self.prefetcher?.stop()
        let prefetcher = ImagePrefetcher(urls: urls)
        prefetcher.start()
        self.prefetcher = prefetcher
    }
    
    func fetchReviews(id: Int, page: Int) async throws -> [ReviewModel] {
        do {
            guard let data = try await networkManager.sendRequest(endpoint: FilmsEndpoints.reviews(filmId: id, page: page), body: nil, authorization: .bearer(token: FilmsEndpoints.TOKEN)) else { throw NSError() }
            
            guard let response: ReviewResponseDTO = decoder.decode(data: data) else { throw NSError() }
            
            return response.results.map({ ReviewModel(from: $0) })
            
        } catch let error {
            throw error
        }
    }
    
    func fetchFilmImages(id: Int) async throws -> ImagesModel {
        do {
            guard let data = try await networkManager.sendRequest(endpoint: FilmsEndpoints.images(filmId: id), body: nil, authorization: .bearer(token: FilmsEndpoints.TOKEN)) else { throw NSError() }
            
            guard let response: ImagesDTO = decoder.decode(data: data) else { throw NSError() }
            
            return ImagesModel(from: response)
        } catch let error {
            throw error
        }
    }
    
    func fetchFilmDetails(id: Int, language: FilmsEndpoints.DiscoverMoviesParams.DescriptionLanguage) async throws -> FilmDetailsModel {
        do {
            guard let data = try await networkManager.sendRequest(endpoint: FilmsEndpoints.details(id: id, language: language), body: nil, authorization: .bearer(token: FilmsEndpoints.TOKEN)) else { throw NSError() }
            
            guard let response: FilmDetailsDTO = decoder.decode(data: data) else { throw NSError() }
            
            return FilmDetailsModel(from: response)
                    
        } catch let error {
            throw error
        }
    }
    
    func fetchFilms(params: FilmsEndpoints.DiscoverMoviesParams) async throws -> [FilmModel] {
        do {
            guard let data = try await networkManager.sendRequest(endpoint: FilmsEndpoints.discoverMovies(params), body: nil, authorization: .bearer(token: FilmsEndpoints.TOKEN)) else { throw NSError() }
            
            guard let response: TMDBResponseDTO<[MovieDTO]> = decoder.decode(data: data) else { throw NSError() }
            
            return response.results.map({ .init(from: $0)})
            
        }
    }
    
    func fetchGenres(language: FilmsEndpoints.DiscoverMoviesParams.DescriptionLanguage) async throws -> [GenreModel] {
        do {
            guard let data = try await networkManager.sendRequest(endpoint: FilmsEndpoints.genres(language: language), body: nil, authorization: .bearer(token: FilmsEndpoints.TOKEN)) else { throw NSError() }
            
            guard let response: GenreDTO = decoder.decode(data: data) else { throw NSError() }
            
            return response.genres.map({ GenreModel(from: $0) })
        }
    }
    
    
}
