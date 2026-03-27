//
//  TabbarView.swift
//  moviehub-iOS
//
//  Created by Pavel Playerz0redd on 24.03.26.
//

import Foundation
import SwiftUI

struct TabbarView: View {
    
    // MARK: - Rx properties
    @ObservedObject private var viewModel: TabViewModel
    
    // MARK: - Init
    init(viewModel: TabViewModel) {
        self.viewModel = viewModel
    }
    
    // MARK: - Body
    var body: some View {
        TabView(selection: $viewModel.selectedTab) {
            ForEach(Tabs.allCases) { tab in
                tab.getView()
                    .tabItem {
                        Label(tab.caption, systemImage: tab.image)
                    }
            }
        }
    }
}
