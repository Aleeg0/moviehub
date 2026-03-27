//
//  Tabs.swift
//  moviehub-iOS
//
//  Created by Pavel Playerz0redd on 24.03.26.
//

import Foundation
import SwiftUI

enum Tabs: Int, CaseIterable, Identifiable, Hashable {
    
    case profile
    case main
    case lists
    
    var id: Int { self.rawValue }
    
    var caption: LocalizedStringResource {
        switch self {
        case .profile:
            "Profile"
        case .main:
            "Main"
        case .lists:
            "Lists"
        }
    }
    
    var image: String {
        switch self {
        case .profile:
            "person"
        case .main:
            "house"
        case .lists:
            "list.bullet"
        }
    }
}

extension Tabs {
    
    @ViewBuilder
    func getView() -> some View {
        switch self {
        case .profile:
            ProfileFlowView()
        case .main:
            Text("MAIN")
        case .lists:
            Text("LISTS")
        }
    }
}
