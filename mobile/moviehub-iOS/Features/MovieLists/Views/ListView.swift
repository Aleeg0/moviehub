//
//  ListView.swift
//  moviehub-iOS
//
//  Created by Pavel Playerz0redd on 19.04.26.
//

import Foundation
import SwiftUI
import Kingfisher

struct ListView: View {
    private let movies: [MovieListModel]
    private let genres: [Int: String]
    
    init(movies: [MovieListModel], genres: [Int: String]) {
        self.movies = movies
        self.genres = genres
    }
    
    var body: some View {
        if movies.isEmpty {
            ContentUnavailableView {
                Label("Ничего не найдено", systemImage: "film.stack")
            } description: {
                Text("Оценивай фильмы на главном экране")
            }
        } else {
            List {
                //LazyVStack(spacing: 10) {
                    ForEach(movies, id: \.self) { movie in
                        movieView(movie: movie)
                            .listRowSeparator(.hidden)
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(action: {}) {
                                    VStack {
                                        Image(systemName: "star")
                                        Text("Звезда")
                                    }
                                }
                                .tint(.orange)
                                Button(action: {}) {
                                    VStack {
                                        Image(systemName: "star")
                                        Text("Звезда")
                                    }
                                }
                            }
                    }
                //}
            }
            .listStyle(.plain)
            .listRowSeparator(.hidden)
            .contentMargins(.bottom, 70, for: .scrollContent)
        }
    }
}

private extension ListView {
    func movieView(movie: MovieListModel) -> some View {
        HStack(alignment: .top, spacing: 10) {
            posterView(posterPath: movie.posterPath)
            
            movieInfoView(movie: movie)
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(10)
        .background {
            RoundedRectangle(cornerRadius: 20)
                .foregroundStyle(.achievementGray)
        }
    }
    
    func movieInfoView(movie: MovieListModel) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(movie.title)
                .font(.system(size: 23, weight: .semibold))
                .foregroundStyle(.white)
            
            HStack {
                ratingView(rating: movie.voteAverage)
                
                Text(String(Calendar.current.component(.year, from: movie.releaseDate)))
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background {
                        Capsule()
                            .foregroundStyle(.profileAvatarBlue)
                    }
            }
            if let genreId = movie.genreId, let genre = genres[genreId] {
                Text(genre)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background {
                        Capsule()
                            .foregroundStyle(.profileAvatarBlue)
                    }
            }
        }
    }
    
    func ratingView(rating: Double) -> some View {
        HStack(spacing: 3) {
            Image(systemName: "star.fill")
                .font(.system(size: 22))
            
            Text("\(rating, specifier: "%.1f")")
                .font(.system(size: 17, weight: .semibold))
        }
        .foregroundStyle(.yellow)
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background {
            Capsule()
                .foregroundStyle(.yellow.opacity(0.6))
        }
    }
    
    func posterView(posterPath: String) -> some View {
        KFImage(URL(string: posterPath))
            .resizable()
            .scaledToFill()
            .frame(width: 160, height: 200)
            .clipped() 
            .clipShape(.rect(cornerRadius: 20))
    }
}
