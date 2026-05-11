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
    
    static var purpleGradient: LinearGradient {
        .init(colors: [Color(red: 138/255, green: 35/255, blue: 135/255), Color(red: 233/255, green: 64/255, blue: 87/255), Color(red: 138/255, green: 35/255, blue: 135/255) ], startPoint: .leading, endPoint: .trailing)
    }
}
