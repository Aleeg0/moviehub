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
    @ObservedObject private var viewModel: MovieListsViewModel
    private let movies: [MovieListModel]
    private let genres: [Int: String]
    private let tab: MovieListsViewModel.Tabs
    
    init(viewModel: MovieListsViewModel, movies: [MovieListModel], genres: [Int: String], tab: MovieListsViewModel.Tabs) {
        self.movies = movies
        self.genres = genres
        self.tab = tab
        self.viewModel = viewModel
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
                ForEach(movies, id: \.self) { movie in
                    movieView(movie: movie)
                        .listRowSeparator(.hidden)
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            ForEach(getTrailingActionSet(for: tab), id: \.self) { action in
                                swipeButton(swipeAction: action, action: { getAction(swipeAction: action, movie: movie) })
                            }
                        }
                        .swipeActions(edge: .leading, allowsFullSwipe: true) {
                            ForEach(getLeadingActionSet(for: tab), id: \.self) { action in
                                swipeButton(swipeAction: action, action:  { getAction(swipeAction: action, movie: movie) })
                            }
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                }
            }
            .listStyle(.plain)
            .listRowSeparator(.hidden)
            .contentMargins(.bottom, 70, for: .scrollContent)
        }
    }
}

private extension ListView {
    enum SwipeAction {
        case delete
        case toLikes
        case toViewed
        case toDislikes
        case rate
        
        var title: LocalizedStringResource {
            switch self {
            case .delete:
                return "Delete"
            case .toLikes:
                return "Add to Likes"
            case .toViewed:
                return "Add to Viewed"
            case .toDislikes:
                return "Add to Dislikes"
            case .rate:
                return "Rate a film"
            }
        }
        
        var icon: String {
            switch self {
            case .delete:
                return "trash"
            case .toLikes:
                return "heart.fill"
            case .toViewed:
                return "eye.fill"
            case .toDislikes:
                return "hand.thumbsdown.fill"
            case .rate:
                return "star.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .delete:
                    .red
            case .toLikes:
                    .green
            case .toViewed:
                    .blue
            case .toDislikes:
                    .purple
            case .rate:
                    .orange
            }
        }
        
    }
    
    func getAction(swipeAction: SwipeAction, movie: MovieListModel) {
        switch swipeAction {
        case .delete:
            viewModel.deleteMovie(movieId: movie.id)
        case .toLikes:
            viewModel.changeStatus(newStatus: .liked, movie: movie)
        case .toViewed:
            viewModel.changeStatus(newStatus: .viewed, movie: movie)
        case .toDislikes:
            viewModel.changeStatus(newStatus: .disliked, movie: movie)
        case .rate:
            viewModel.changeStatus(newStatus: .viewed, movie: movie)
        }
    }
    
    func getLeadingActionSet(for tab: MovieListsViewModel.Tabs) -> [SwipeAction] {
        switch tab {
        case .liked:
            []
        case .disliked:
            []
        case .watched:
            [.rate]
        }
    }
    
    func getTrailingActionSet(for tab: MovieListsViewModel.Tabs) -> [SwipeAction] {
        switch tab {
        case .liked:
            [.delete, .toDislikes, .toViewed]
        case .disliked:
            [.delete, .toLikes, .toViewed]
        case .watched:
            [.delete, .toDislikes, .toLikes]
        }
    }
    
    
}

private extension ListView {
    func swipeButton(swipeAction: SwipeAction, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack {
                Image(systemName: swipeAction.icon)
                    .font(.system(size: 30))
                Text(swipeAction.title)
                    .font(.system(size: 17, weight: .semibold))
            }
        }
        .tint(swipeAction.color)
    }
}

private extension ListView {
    func movieView(movie: MovieListModel) -> some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top, spacing: 10) {
                posterView(posterPath: movie.posterPath)
                
                movieInfoView(movie: movie)
                
                Spacer()
            }
            if let comment = movie.comment {
                Text("'\(comment)'")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(.secondary)
                    .italic()
            }
        }
        .frame(maxWidth: .infinity)
        .padding(10)
        .background {
            RoundedRectangle(cornerRadius: 20)
                .foregroundStyle(.achievementGray)
        }
    }
    
    @ViewBuilder
    func starsView(movie: MovieListModel) -> some View {
        if let rating = movie.rating {
            HStack(spacing: 5) {
                ForEach(1..<6, id: \.self) { index in
                    starView(isSelected: rating >= index)
                }
            }
        }
    }
    
    @ViewBuilder
    func starView(isSelected: Bool) -> some View {
        ZStack {
            if isSelected {
                Image(systemName: "star.fill")
                    .foregroundStyle(.yellow)
            } else {
                Image(systemName: "star")
                    .foregroundStyle(.gray)
            }
        }
        .font(.system(size: 23, weight: .semibold))
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
            
            starsView(movie: movie)
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
            .setProcessor(DownsamplingImageProcessor(size: CGSize(width: 160, height: 200)))
            .scaleFactor(UIScreen.main.scale)
            .cacheOriginalImage()
            .resizable()
            .scaledToFill()
            .frame(width: 160, height: 200)
            .clipped() 
            .clipShape(.rect(cornerRadius: 20))
    }
}
