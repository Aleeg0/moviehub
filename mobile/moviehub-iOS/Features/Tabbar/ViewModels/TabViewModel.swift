//
//  TabViewModel.swift
//  moviehub-iOS
//
//  Created by Pavel Playerz0redd on 24.03.26.
//

import Foundation
import Combine

final class TabViewModel: ObservableObject {
    @Published var selectedTab: Tabs = .profile
}
