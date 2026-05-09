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
        .scaleEffect(viewModel.isShowingRateView ? 0.95 : 1)
        .blur(radius: viewModel.isShowingRateView ? 20 : 0)
        .animation(.bouncy, value: viewModel.isShowingRateView)
        .sheet(isPresented: $viewModel.isShowingDetails) {
            FilmDetailsView(viewModel: .init(filmsProvider: FilmsProvider(networkManager: NetworkManager(), decoder: DecodeManager()), filmId: viewModel.selectedFilmId ?? 1))
        }
        .overlay {
            if viewModel.isShowingRateView {
                rateFilmView(title: viewModel.visibleFilms.first?.title ?? "No title")
            }
        }
    }
    
}

private extension FilmStackView {
    func rateFilmView(title: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            rateHeaderView(title: title)
            Divider()
            Text("Ваша оценка")
                .font(.system(size: 18, weight: .medium))
            starsView
            noteView
            buttonsView
        }
        .padding(20)
        .background {
            RoundedRectangle(cornerRadius: 45)
                .foregroundStyle(.achievementGray)
        }
        .animation(.bouncy, value: viewModel.selectedStarsCount)
    }
    
    var buttonsView: some View {
        HStack(spacing: 20) {
            capsuleButton(title: "Отмена", color: .pickerGray, isActive: true, action: { viewModel.isShowingRateView = false } )
            capsuleButton(title: "Сохранить", color: .authGradient, isActive: true, action: viewModel.sendViewedMovie )
        }
    }
    
    func capsuleButton<Style: ShapeStyle>(title: LocalizedStringResource, color: Style, isActive: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .foregroundStyle(.white)
                .font(.system(size: 18, weight: .semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .background {
                    Capsule()
                        .foregroundStyle(color)
                }
                .disabled(!isActive)
        }
    }
    
    var noteView: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Ваша заметка")
                .font(.system(size: 18, weight: .medium))
            
            TextEditor(text: $viewModel.noteString)
                .frame(maxHeight: 150)
                .scrollContentBackground(.hidden)
                .padding(10)
                .background(.achievementGray)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.blue, lineWidth: 2)
                )
                .overlay(alignment: .topLeading) {
                    if viewModel.noteString.isEmpty {
                        Text("Что вы думаете об этом фильме?")
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 13)
                            .padding(.vertical, 15)
                    }
                }
                .font(.system(size: 17, weight: .semibold))
            
        }
    }
    
    func rateHeaderView(title: String) -> some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(.white)
            
            Text("Оцените фильм")
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(.secondary)
        }
    }
    
    var starsView: some View {
        HStack(spacing: 10) {
            ForEach(1..<6, id: \.self) { index in
                Button(action: { viewModel.selectedStarsCount = index }) {
                    starView(isSelected: viewModel.selectedStarsCount >= index)
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
        .font(.system(size: 34, weight: .semibold))
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


