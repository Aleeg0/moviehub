//
//  AuthGradient.swift
//  moviehub-iOS
//
//  Created by Pavel Playerz0redd on 21.03.26.
//

import Foundation
import SwiftUI

extension ShapeStyle where Self == LinearGradient {
    static var authGradient: LinearGradient {
        .init(colors: [.authBlueTop, .authBlueDown], startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}
