//
//  BeamTextField.swift
//  moviehub-iOS
//
//  Created by Pavel Playerz0redd on 10.05.26.
//

import Foundation
import SwiftUI

struct BeamTextField<Style: ShapeStyle>: View {
    
    @Binding private var text: String
    private let placeholder: LocalizedStringResource
    private let backgroundColor: Style
    
    init(text: Binding<String>, placeholder: LocalizedStringResource, backgroundColor: Style) {
        self._text = text
        self.placeholder = placeholder
        self.backgroundColor = backgroundColor
    }
    
    var body: some View {
        
        TextField("", text: $text, prompt: Text(placeholder).font(.system(size: 20, weight: .semibold))            .foregroundStyle(.pickerGray))
            .foregroundStyle(.pickerGray)
            .frame(maxWidth: .infinity)
            .font(.system(size: 20, weight: .semibold))
            .padding(16)
            .background {
                beamBackground
            }
    }
    
    var beamBackground: some View {
        ZStack {
            Capsule()
                .foregroundStyle(backgroundColor)
            
            KeyframeAnimator(initialValue: 0.0, repeating: true) { value in
                let rotation = 360 * value
                
                let borderGradient = AngularGradient(
                    colors: [.clear, .white, .clear],
                    center: .center,
                    startAngle: .degrees(140 + rotation),
                    endAngle: .degrees(270 + rotation)
                )
                
                let beamGradient = LinearGradient(
                    colors: [.green, .blue, .red, .orange, .indigo],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                Capsule()
                    .fill(beamGradient)
                    .mask {
                        Capsule()
                            .overlay {
                                Capsule()
                                    .blur(radius: 15)
                                    .blendMode(.destinationOut)
                            }
                    }
                    .mask {
                        Capsule()
                            .fill(borderGradient)
                    }
                
                Capsule()
                    .stroke(borderGradient, lineWidth: 0.6)
            } keyframes: { _ in
                LinearKeyframe(1, duration: 2.5)
            }

        }
    }

}
