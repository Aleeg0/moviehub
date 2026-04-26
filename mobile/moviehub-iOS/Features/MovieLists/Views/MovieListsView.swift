//
//  MovieListsView.swift
//  moviehub-iOS
//
//  Created by Pavel Playerz0redd on 19.04.26.
//

import Foundation
import SwiftUI

struct MovieListsView: View {
    @StateObject private var viewModel: MovieListsViewModel = .init()
    @Namespace private var namespace
    
    var body: some View {
        VStack(spacing: 10) {
            
            headerView
                //.padding(.horizontal, 20)
            
            tabView
                //.padding(.horizontal, 20)
            
            GeometryReader { geo in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 0) {
                        ForEach(MovieListsViewModel.Tabs.allCases, id: \.self) { tab in
                            ListView(movies: viewModel.films.filter({ movie in
                                switch tab {
                                case .liked:         movie.status == .liked && movie.genreId != nil
                                case .disliked:      movie.status == .disliked && movie.genreId != nil
                                case .watched:        movie.status == .viewed && movie.genreId != nil
                                }
                            }), genres: viewModel.genres)
                                .padding(10)
                                .frame(width: geo.size.width)
                                .id(tab)
                                .tag(tab)
                        }
                        
                    }
                    .scrollTargetLayout()
                }
                .scrollTargetBehavior(.paging)
                .scrollPosition(id: createScrollPositionBinding())
            }
        }
        .animation(.easeInOut, value: viewModel.films)
        .ignoresSafeArea(edges: .bottom)
        .animation(.bouncy, value: viewModel.selectedTab)
        .navigationTitle("Мои списки")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.fetchFilms()
        }
    }
    
    private func createScrollPositionBinding() -> Binding<MovieListsViewModel.Tabs?> {
            Binding(
                get: { viewModel.selectedTab },
                set: { newValue in
                    if let newTab = newValue {
                        viewModel.selectedTab = newTab
                    }
                }
            )
        }
    
}

private extension MovieListsView {
    var tabView: some View {
        HStack(spacing: 50) {
            ForEach(MovieListsViewModel.Tabs.allCases, id: \.self) { tab in
                tabView(tab: tab, isSelected: viewModel.selectedTab == tab)
                    .onTapGesture {
                        viewModel.selectedTab = tab
                    }
            }
        }
        .frame(maxWidth: .infinity)
    }
}

private extension MovieListsView {
    
    func tabView(tab: MovieListsViewModel.Tabs, isSelected: Bool) -> some View {
        VStack(spacing: 3) {
            Image(systemName: tab.image)
                .font(.system(size: 33))
                .foregroundStyle(isSelected ? .white : .gray)
                .frame(height: 40)
            
            Text(tab.caption)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(isSelected ? .white : .gray)
            
            ZStack {
                if isSelected {
                    Rectangle()
                        .foregroundStyle(.white)
                        .matchedGeometryEffect(id: "tab", in: namespace)
                }
            }
            .frame(width: 100, height: 2)
            
        }
    }
}

private extension MovieListsView {
    var headerView: some View {
        Text("Свайпайте влево или вправо для переключения списков")
            .font(.system(size: 17, weight: .medium))
            .foregroundStyle(.gray.gradient)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
