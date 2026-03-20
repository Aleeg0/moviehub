//
//  AuthTextFieldModifier.swift
//  moviehub-iOS
//
//  Created by Pavel Playerz0redd on 21.03.26.
//

import Foundation
import SwiftUI

struct AuthTextFieldModifier: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .font(.system(size: 20, weight: .semibold))
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(Capsule().foregroundStyle(.pickerGray))
    }
    
    
}
