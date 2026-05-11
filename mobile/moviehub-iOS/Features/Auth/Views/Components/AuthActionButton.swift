//
//  AuthActionButton.swift
//  moviehub-iOS
//
//  Created by Pavel Playerz0redd on 21.03.26.
//

import Foundation
import SwiftUI

struct AuthActionButton<Style: ShapeStyle>: View {
    private let caption: LocalizedStringResource
    private let action: () -> Void
    private let style: Style
    
    init(caption: LocalizedStringResource, style: Style, action: @escaping () -> Void) {
        self.action = action
        self.caption = caption
        self.style = style
    }
    
    var body: some View {
        Button(action: action) {
            Text(caption)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .font(.system(size: 20, weight: .semibold))
                .background(Capsule().foregroundStyle(style))
        }
    }
}
