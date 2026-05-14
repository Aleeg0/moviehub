//
//  FilmDetailsView.swift
//  moviehub-iOS
//
//  Created by Pavel Playerz0redd on 9.04.26.
//

import Foundation
import SwiftUI
import Kingfisher
import Shimmer

struct FilmDetailsView: View {
    
    @ObservedObject private var viewModel: FilmDetailsViewModel
    
    init(viewModel: FilmDetailsViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ZStack {
            switch viewModel.viewState {
            case .success:
                detailsView
            case .loading:
                sceletonView
            case .error:
                Text("Error")
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 30)
        .ignoresSafeArea()
        .animation(.bouncy, value: viewModel.viewState)
    }

}

private extension FilmDetailsView {
    var detailsView: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                
                posterView
                
                Text(viewModel.details?.title ?? "No title")
                    .font(.largeTitle.bold())
                
                ratingView
                
                infoSection
                
                genresView
                
                filmDescriptionBlock
                
                if let images = viewModel.images, !images.backdrops.isEmpty {
                    mediaListView(title: "Backdrops", media: Array(images.backdrops.prefix(3)))
                }
                
                if let images = viewModel.images, !images.posters.isEmpty {
                    mediaListView(title: "Posters", media: Array(images.posters.prefix(3)))
                }
                
                if let images = viewModel.images, !images.logos.isEmpty {
                    mediaListView(title: "Logos", media: Array(images.logos.prefix(3)))
                }
                
                if !viewModel.reviews.isEmpty {
                    reviewsView
                }
            }
        }
    }
}

private extension FilmDetailsView {
    var sceletonView: some View {
        ScrollView {
            VStack(spacing: 20) {
                RoundedRectangle(cornerRadius: 20)
                    .frame(maxWidth: .infinity)
                    .frame(height: 400)
                
                HStack(spacing: 10) {
                    RoundedRectangle(cornerRadius: 20)
                        .frame(maxWidth: .infinity)
                        .frame(height: 130)
                    
                    RoundedRectangle(cornerRadius: 20)
                        .frame(maxWidth: .infinity)
                        .frame(height: 130)
                }
                
                RoundedRectangle(cornerRadius: 20)
                    .frame(maxWidth: .infinity)
                    .frame(height: 130)
                
                RoundedRectangle(cornerRadius: 20)
                    .frame(maxWidth: .infinity)
                    .frame(height: 300)
            }
        }
        .foregroundStyle(.gray)
        .shimmering()
    }
}

private extension FilmDetailsView {
    var reviewsView: some View {
        VStack(alignment: .leading) {
            
            Text("Reviews")
                .font(.system(size: 28, weight: .semibold))
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(viewModel.reviews, id: \.self) { review in
                        reviewView(review: review)
                    }
                }
            }
        }
    }
}

private extension FilmDetailsView {
    func reviewView(review: ReviewModel) -> some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                if let _ = review.authorDetails.avatarPath {
                    KFImage(review.authorDetails.avatarUrl)
                        .resizable()
                        .frame(width: 50, height: 50)
                        .scaledToFill()
                        .clipShape(Circle())
                } else {
                    Image(systemName: "person.circle")
                        .foregroundStyle(.profileAvatarBlue)
                        .font(.system(size: 40))
                        .frame(width: 50, height: 50)
                        .scaledToFill()
                        .clipShape(Circle())
                }
                
                VStack(alignment: .leading) {
                    Text(review.author)
                        .font(.system(size: 14))
                    
                    Text(review.createdAt.formatted(.dateTime.day().month(.wide).year()))
                        .font(.system(size: 14))
                        .foregroundStyle(.gray)
                }
            }
            
            Text("\(review.content.split(separator: " ").prefix(20).joined(separator: " "))...")
                .font(.system(size: 14))
                .multilineTextAlignment(.leading)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
        }
        .frame(width: 300, height: 200)
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 20)
                .foregroundStyle(.inputSectionGray)
        }
        .padding(.bottom, 25)
    }
}

private extension FilmDetailsView {
    func mediaListView<Media: IMediaImage>(title: LocalizedStringResource, media: [Media]) -> some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.system(size: 28, weight: .semibold))
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(media, id: \.self) { image in
                        KFImage(image.url)
                            .placeholder {
                                ZStack {
                                    Color.gray.opacity(0.2)
                                    ProgressView()
                                        .controlSize(.large) 
                                }
                            }
                            .resizable()
                            .aspectRatio(image.aspectRation, contentMode: .fit)
                            .frame(height: 200)
                            .clipped()
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                }
            }
        }
    }
}

private extension FilmDetailsView {
    var infoSection: some View {
        VStack(spacing: 15) {
            HStack(spacing: 15) {
                rectangeWithContent(title: "Year", image: "calendar", content: "\(Calendar.current.component(.year, from: viewModel.details?.releaseTime ?? .init()))")
                
                rectangeWithContent(title: "Runtime", image: "clock", content: "\(viewModel.details?.runtime ?? 0)min")
            }
            
            rectangeWithContent(title: "Original title", image: "pencil.line", content: "\(viewModel.details?.originalTitle ?? "no title")")
        }
    }
}


private extension FilmDetailsView {
    func rectangeWithContent(title: LocalizedStringResource, image: String, content: LocalizedStringResource) -> some View {
        
        VStack(alignment: .leading, spacing: 10) {
            
            HStack(alignment: .top) {
                Image(systemName: image)
                    .foregroundStyle(.authBlueTop)
                    .font(.system(size: 22))
                
                Text(title)
                    .font(.system(size: 19, weight: .medium))
                    .foregroundStyle(.gray)
            }
            
            Text(content)
                .font(.system(size: 21, weight: .semibold))
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: 18)
                .foregroundStyle(.achievementGray)
        }
    }
}

private extension FilmDetailsView {
    var filmDescriptionBlock: some View {
        VStack(alignment: .leading, spacing: 10) {
            
            Text("Description")
                .font(.system(size: 25, weight: .semibold))
            
            Text(viewModel.details?.overview ?? "Description")
                .foregroundStyle(.gray)
                .font(.system(size: 20, weight: .medium))
                .multilineTextAlignment(.leading)
        }
    }
}

private extension FilmDetailsView {
    
    var genresView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(viewModel.details?.genres ?? [], id: \.self) { genre in
                    Text(genre.name.capitalized)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 7)
                        .background {
                            Capsule()
                                .foregroundStyle(.authBlueTop)
                        }
                }
            }
        }
    }
    
}

private extension FilmDetailsView {
    
    var ratingView: some View {
        HStack {
            HStack {
                Image(systemName: "star.fill")
                    .font(.system(size: 27))
                
                Text(String(format: "%.1f", viewModel.details?.voteAverage ?? 2))
                    .font(.system(size: 27, weight: .medium))
            }
            .foregroundStyle(.yellow)
            .padding(.vertical, 6)
            .padding(.horizontal, 10)
            .background {
                Capsule()
                    .foregroundStyle(.yellow.opacity(0.6))
            }
            
            Text("IMDb")
                .foregroundStyle(.gray)
                .font(.system(size: 26))
        }
    }
}

private extension FilmDetailsView {
    private var posterView: some View {
        KFImage(URL(string: viewModel.details?.image ?? ""))
            .resizable()
            .scaledToFill()
            .frame(minWidth: 0, maxWidth: .infinity)
            .frame(height: 400)
            .overlay {
                LinearGradient(colors: [.black.opacity(0), .black.opacity(0.3), .black.opacity(1)], startPoint: .top, endPoint: .bottom)
            }
            .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}
