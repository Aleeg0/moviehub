//
//  FilmDetailsView.swift
//  moviehub-iOS
//
//  Created by Pavel Playerz0redd on 9.04.26.
//

import Foundation
import SwiftUI
import Kingfisher

struct FilmDetailsView: View {
    
    @ObservedObject private var viewModel: FilmDetailsViewModel
    
    init(viewModel: FilmDetailsViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        
    }

}

private extension FilmDetailsView {
    private var posterView: some View {
        KFImage(URL(string: viewModel.details?.image ?? ""))
            .resizable()
            .frame(maxWidth: .infinity)
            .aspectRatio(16/9, contentMode: .fill)
            .overlay {
                LinearGradient(colors: [.black.opacity(0), .black.opacity(0.3), .black.opacity(1)], startPoint: .top, endPoint: .bottom)
            }
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: 23))
    }
}
