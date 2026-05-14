//
//  ProvidersView.swift
//  moviehub-iOS
//
//  Created by Pavel Playerz0redd on 10.05.26.
//

import Foundation
import SwiftUI
import Kingfisher

struct ProvidersView: View {
    @ObservedObject private var viewModel: ProvidersViewModel
    
    init(viewModel: ProvidersViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack {
            BeamTextField(text: $viewModel.findText, placeholder: "Поиск", backgroundColor: .white.gradient)
                .autocorrectionDisabled()
            
            ScrollView(showsIndicators: false) {
                
                headerView
                
                LazyVGrid(columns: [.init(), .init()]) {
                    ForEach(viewModel.visibleProviders.sorted(by: { $0.priority < $1.priority} ), id: \.self) { provider in
                        providerView(provider: provider, isSelected: viewModel.selectedProviders.contains(provider))
                    }
                }
            }
            .ignoresSafeArea(edges: .bottom)
            .animation(.bouncy, value: viewModel.visibleProviders)
        }
        .overlay(alignment: .bottom) {
            AuthActionButton(caption: "Сохранить", style: .purpleGradient, action: viewModel.uploadProviders)
        }
        .padding(.horizontal, 10)
        .background {
            Color.profileAvatarBlue
                .ignoresSafeArea()
        }
    }
    
    var headerView: some View {
        VStack(spacing: 10) {
            Text("Выберите ваши сервисы")
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(.white)
            
            Text("Отметьте стриминговые сервисы, которые у вас подключены")
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(.secondary)
        }
        .multilineTextAlignment(.center)
    }
}

private extension ProvidersView {
    func providerView(provider: ProviderModel, isSelected: Bool) -> some View {
        Button(action: { viewModel.pickProvider(provider: provider) }) {
            VStack(spacing: 10) {
                KFImage(URL(string: provider.logoPath))
                    .scaleFactor(UIScreen.main.scale)
                    .cacheOriginalImage()
                    .resizable()
                    .scaledToFill()
                    .frame(width: 130, height: 130)
                    .clipped()
                    .clipShape(.rect(cornerRadius: 20))
                
                Text(provider.name)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(10)
            .background {
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? .green : .pickerGray, lineWidth: 2)
            }
            .overlay(alignment: .topTrailing) {
                Image(systemName: "checkmark.circle")
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundColor(.green)
                    .opacity(isSelected ? 1 : 0)
                    .padding(15)
            }
        }
        .padding(2)
    }
}
