//
//  RateView.swift
//  moviehub-iOS
//
//  Created by Pavel Playerz0redd on 10.05.26.
//

import Foundation
import SwiftUI

struct RateView: View {
    private let title: String
    @Binding private var selectedStars: Int
    @Binding private var noteString: String
    private let onDismiss: () -> Void
    private let onSave: () -> Void
    
    init(title: String, selectedStars: Binding<Int>, noteString: Binding<String>, onDismiss: @escaping () -> Void, onSave: @escaping () -> Void) {
        self.title = title
        self._selectedStars = selectedStars
        self._noteString = noteString
        self.onDismiss = onDismiss
        self.onSave = onSave
    }
    
    var body: some View {
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
        .animation(.bouncy, value: selectedStars)
    }
    
    var buttonsView: some View {
        HStack(spacing: 20) {
            capsuleButton(title: "Отмена", color: .pickerGray, isActive: true, action: onDismiss )
            capsuleButton(title: "Сохранить", color: .authGradient, isActive: true, action: onSave )
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
            
            TextEditor(text: $noteString)
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
                    if noteString.isEmpty {
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
                Button(action: { selectedStars = index }) {
                    starView(isSelected: selectedStars >= index)
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
