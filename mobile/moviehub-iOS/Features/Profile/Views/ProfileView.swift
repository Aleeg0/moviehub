//
//  ProfileView.swift
//  moviehub-iOS
//
//  Created by Pavel Playerz0redd on 24.03.26.
//

import Foundation
import SwiftUI

struct ProfileView: View {
    
    // MARK: - Rx properties
    @ObservedObject private var viewModel: ProfileViewModel
    
    // MARK: - Init
    init(viewModel: ProfileViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                infoBlock
                
                achievementsSection
                
                achievements
                    .padding(.horizontal, 1)
                
                Spacer()
            }
        }
        .padding(.horizontal, 15)
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: viewModel.signOut) {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .font(.system(size: 18))
                }
            }
        }
    }
    
    var achievements: some View {
        VStack(spacing: 20) {
            HStack(spacing: 20) {
                achievementView(caption: "Первый фильм", image: "film")
                
                achievementView(caption: "5 фильмов", image: "chart.line.uptrend.xyaxis")
            }
            
            HStack(spacing: 20) {
                achievementView(caption: "5 звезд", image: "star")
                
                achievementView(caption: "Первая заметка", image: "calendar")
            }
        }
    }
    
    func achievementView(caption: LocalizedStringResource, image: String) -> some View {
        VStack {
            Image(systemName: image)
                .font(.system(size: 25, weight: .semibold))
                .frame(width: 40, height: 40)
                .foregroundStyle(.white)
                .padding(8)
                .background(Circle().foregroundStyle(.achievementGray))
            
            Text(caption)
                .font(.system(size: 19, weight: .medium))
                .multilineTextAlignment(.center)
                .foregroundStyle(.achievementGray)
                .frame(maxWidth: 100)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 180)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .stroke(Color.achievementGray, lineWidth: 2)
                .foregroundStyle(.pickerGray)
        )
    }
    
    var achievementsSection: some View {
        HStack {
            Image(systemName: "medal.fill")
                .font(.system(size: 24))
                .foregroundStyle(.authBlueTop)
            
            Text("Achievements")
                .font(.system(size: 24, weight: .semibold))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    var infoBlock: some View {
        VStack(spacing: 30) {
            userInfoBlock
            
            HStack(spacing: 12) {
                statisticsView(caption: "Просмотрено") {
                    Text("0")
                        .font(.system(size: 25, weight: .semibold))
                }
                
                statisticsView(caption: "Хочу") {
                    Text("0")
                        .font(.system(size: 25, weight: .semibold))
                }
                
                statisticsView(caption: "Средняя") {
                    HStack(spacing: 5) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 27))
                            .foregroundStyle(.yellow)
                        
                        Text("0")
                            .font(.system(size: 25, weight: .semibold))
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(22)
        .background(RoundedRectangle(cornerRadius: 32).foregroundStyle(.authGradient))
    }
    
    func statisticsView<Content: View>(
        caption: LocalizedStringResource,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(spacing: 10) {
            content()
            
            Text(caption)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 100)
        .background {
            RoundedRectangle(cornerRadius: 23)
                .foregroundStyle(.profileAvatarBlue)
        }
    }
    
    var userInfoBlock: some View {
        HStack {
            avatarView
            
            VStack(alignment: .leading, spacing: 10) {
                Text(viewModel.userModel?.name ?? "Username")
                    .font(.system(size: 25, weight: .semibold))
                
                Text(viewModel.userModel?.email ?? "Email")
                    .font(.system(size: 19, weight: .regular))
                    .foregroundStyle(.gray)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    var avatarView: some View {
        Text(viewModel.nameFirstLetter)
            .font(.system(size: 27, weight: .medium))
            .foregroundStyle(.white)
            .padding(30)
            .background(Circle().foregroundStyle(.profileAvatarBlue))
    }
}
