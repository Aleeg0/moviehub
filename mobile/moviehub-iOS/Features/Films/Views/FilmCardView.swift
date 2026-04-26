//
//  FilmCardView.swift
//  moviehub-iOS
//
//  Created by Pavel Playerz0redd on 6.04.26.
//

import Foundation
import SwiftUI
import Kingfisher

struct FilmCardView: View {
    
    private let film: FilmModel
    private let onSwipe: (FilmsViewModel.SwipeStatus) -> Void
    private let genres: String
    private let onOpenDescription: (Int) -> Void
    
    @State private var offset: CGSize = .zero
    @State private var angle: CGFloat = .zero
    
    init(film: FilmModel, genres: String, onSwipe: @escaping (FilmsViewModel.SwipeStatus) -> Void, onOpenDescription: @escaping (Int) -> Void) {
        self.film = film
        self.genres = genres
        self.onSwipe = onSwipe
        self.onOpenDescription = onOpenDescription
    }
    
    var body: some View {
        if let image = film.image {
            imageView(imagePath: image)
        } else {
            Text("No Image")
                .frame(width: 350, height: 500)
                .background {
                    RoundedRectangle(cornerRadius: 27)
                        .foregroundStyle(.achievementGray)
                }
        }
    }
    
    func imageView(imagePath: String) -> some View {
        KFImage(URL(string: imagePath))
            .placeholder {
                ZStack {
                    Color.gray.opacity(0.2)
                    ProgressView()
                        .controlSize(.large)
                }
            }
            .resizable()
            .scaledToFill()
            .frame(width: 350, height: 500)
            .overlay {
                LinearGradient(colors: [.black.opacity(0), .black.opacity(0.3), .black.opacity(0.9)], startPoint: .top, endPoint: .bottom)
            }
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: 27))
            .overlay(alignment: .topTrailing) {
                descriptionButton
                    .padding(20)
            }
            .overlay(alignment: .top) {
                HStack {
                    swipeOverlay(
                        title: "WANT",
                        color: .blue,
                        condition: abs(offset.width) > abs(offset.height)
                    )
                    .opacity(CGFloat(offset.width / 50))
                    .rotationEffect(.degrees(-30))
                    
                    Spacer()
                    
                    swipeOverlay(
                        title: "DONT WANT",
                        color: .red,
                        condition: abs(offset.width) > abs(offset.height)
                    )
                    .opacity(CGFloat(-offset.width / 50))
                    .rotationEffect(.degrees(30))
                }
            }
            .overlay(alignment: .center) {
                swipeOverlay(
                    title: "WATCHED",
                    color: .green,
                    condition: abs(offset.width) < abs(offset.height)
                )
                .opacity(CGFloat(-offset.height / 80))
            }
            .overlay(alignment: .bottomLeading) {
                infoSection
            }
            .gesture(
                DragGesture()
                    .onChanged(onDragChange)
                    .onEnded(onDragEnd)
            )
            .rotationEffect(.degrees(angle))
            .offset(offset)
            .animation(.snappy, value: offset)
            .animation(.smooth, value: angle)
                
    }
    
}

private extension FilmCardView {
    
    var descriptionButton: some View {
        Button {
            onOpenDescription(film.id)
        } label: {
            Image(systemName: "info.circle")
                .font(.system(size: 43))
                .padding(7)
                .background {
                    Circle()
                        .foregroundStyle(.achievementGray)
                        .opacity(0.85)
                }
                .foregroundStyle(.white)
        }

    }
}

private extension FilmCardView {
    
    func onDragChange(gesture: _ChangedGesture<DragGesture>.Value) {
        offset = .init(width: gesture.translation.width / 2, height: gesture.translation.height / 2)
        angle = gesture.translation.width / 15
    }
    
    func onDragEnd(gesture: _ChangedGesture<DragGesture>.Value) {
        if abs(gesture.translation.width) > 200 || gesture.translation.height < -300 {
            
            if gesture.translation.width > 200 {
                self.offset.width = 500
                self.onSwipe(.liked)
            }
            
            else if gesture.translation.width < -200 {
                self.offset.width = -500
                self.onSwipe(.disliked)
            }
            
            else if gesture.translation.height < -300 {
                self.offset.height = -1000
                self.onSwipe(.viewed)
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(nil) {
                    offset = .zero
                    angle = .zero
                }
            }
        }
        else {
            angle = .zero
            offset = .zero
        }
    }
}

private extension FilmCardView {
    
    var ratingView: some View {
        HStack {
            Image(systemName: "star.fill")
                .font(.system(size: 25))
            
            Text(String(format: "%.1f", film.rating))
                .font(.system(size: 25, weight: .medium))
        }
        .foregroundStyle(.yellow)
        .padding(8)
        .background {
            Capsule()
                .foregroundStyle(.yellow.opacity(0.6))
        }
    }
    
}

private extension FilmCardView {
    
    @ViewBuilder
    func swipeOverlay(title: LocalizedStringResource, color: Color, condition: Bool) -> some View {
        if condition {
            Text(title)
                .font(.system(size: 23, weight: .semibold))
                .padding(15)
                .background {
                    RoundedRectangle(cornerRadius: 18)
                        .foregroundStyle(color)
                }
                .padding(30)
        }
    }
    
}

private extension FilmCardView {
    
    var infoSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                
                ratingView
                
                Text(String(Calendar.current.component(.year, from: film.releaseDate)))
                    .foregroundStyle(.white)
                    .font(.system(size: 25, weight: .medium))
            }
            
            Text(film.title)
                .font(.system(size: 33, weight: .bold))
            
            Text(genres)
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(.gray)
        }
        .padding(.leading, 20)
        .padding(.bottom, 20)
    }
    
}
