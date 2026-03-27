//
//  PrivateStorageManager.swift
//  moviehub-iOS
//
//  Created by Pavel Playerz0redd on 20.03.26.
//

import Foundation

protocol IPrivateManager {
    
    func store<T>(key: String, object: T)
    func fetch<T>(key: String) -> T?
    func remove(key: String)
}


