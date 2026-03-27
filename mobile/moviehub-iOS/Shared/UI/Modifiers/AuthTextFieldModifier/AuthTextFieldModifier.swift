//
//  AuthTextFieldModifier.swift
//  moviehub-iOS
//
//  Created by Pavel Playerz0redd on 21.03.26.
//

import Foundation
import SwiftUI

struct AuthTextFieldModifier: ViewModifier {
    
    let error: (AuthValidationError)?
    
    func body(content: Content) -> some View {
        content
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .font(.system(size: 20, weight: .semibold))
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background {
                Capsule()
                    .foregroundStyle(.pickerGray)
                    .overlay {
                        Capsule()
                            .stroke(error == nil ? .authBlueDown : .red , lineWidth: 1)
                    }
            }
            .keyframeAnimator(initialValue: 0, trigger: error) { content, value in
                content
                    .offset(x: value)
            } keyframes: { _ in
                KeyframeTrack {
                    if let _ = error {
                        CubicKeyframe(10, duration: 0.1)
                        CubicKeyframe(-10, duration: 0.1)
                        CubicKeyframe(5, duration: 0.1)
                        CubicKeyframe(-5, duration: 0.1)
                        CubicKeyframe(0, duration: 0.1)
                    } else {
                        MoveKeyframe(0)
                    }
                }
            }

    }
    
    
}
