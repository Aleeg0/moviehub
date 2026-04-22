//
//  FilmStackView.swift
//  moviehub-iOS
//
//  Created by Pavel Playerz0redd on 6.04.26.
//

import Foundation
import SwiftUI

struct FilmStackView: View {
    
    @StateObject private var viewModel: FilmsViewModel = .init(
        filmsProvider: FilmsProvider(
                networkManager: NetworkManager(),
                decoder: DecodeManager()
        ), swipeService: SwipeService(dependency: .init(networkManager: NetworkManager(), privateStorage: UserDefaultsStorageManager(), decoder: DecodeManager())))

    var body: some View {
        VStack(spacing: 40) {
            ZStack {
                
                ForEach(viewModel.visibleFilms, id: \.id) { film in
                    
                    let index = viewModel.visibleFilms.firstIndex(of: film) ?? 1
                    
                    FilmCardView(
                        film: film,
                        genres: viewModel.filmGenres(film: film),
                        onSwipe: viewModel.onSwipe,
                        onOpenDescription: { filmId in
                            self.viewModel.showDetails(filmId: filmId)
                        }
                    )
                    .scaleEffect(0.85 + CGFloat(index) * 0.04)
                    .zIndex(-Double(index))
                    .onAppear {
                        if viewModel.films.count < 5 {
                            viewModel.fetchFilms()
                        }
                    }
                }
            }
            .animation(.bouncy, value: viewModel.films)
            
            HStack(spacing: 30) {
                ForEach(FilmsViewModel.ActionButton.allCases, id: \.self) { button in
                    actionButton(type: button)
                }
            }
        }
        .sheet(isPresented: $viewModel.isShowingDetails) {
            FilmDetailsView(viewModel: .init(filmsProvider: FilmsProvider(networkManager: NetworkManager(), decoder: DecodeManager()), filmId: viewModel.selectedFilmId ?? 1))
        }
    }
    
}

private extension FilmStackView {
    func actionButton(type: FilmsViewModel.ActionButton) -> some View {
        Button(
            action: {
                viewModel.handleButton(type: type)
            }) {
            VStack {
                Image(systemName: type.icon)
                    .font(.system(size: 25, weight: .semibold))
                    .frame(width: 40, height: 40)
                    .foregroundStyle(.black)
                    .padding(13)
                    .background {
                        Circle()
                            .foregroundStyle(type.color)
                    }
                
                Text(type.title)
                    .font(.system(size: 17))
                    .foregroundStyle(.gray)
            }
        }
    }
}

private extension FilmsViewModel.ActionButton {
    var color: Color {
        switch self {
        case .dontWant:       .red
        case .want:           .blue
        case .watched:        .green
        }
    }
}


