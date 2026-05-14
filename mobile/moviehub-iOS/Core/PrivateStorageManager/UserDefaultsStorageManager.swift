//
//  UserDefaultsStorageManager.swift
//  moviehub-iOS
//
//  Created by Pavel Playerz0redd on 20.03.26.
//

import Foundation


final class UserDefaultsStorageManager: IPrivateManager {
    
    private let storage = UserDefaults()
    
    func store<T>(key: String, object: T) {
        storage.setValue(object, forKey: key)
    }
    
    func fetch<T>(key: String) -> T? {
        storage.value(forKey: key) as? T
    }
    
    func remove(key: String) {
        storage.removeObject(forKey: key)
    }
    
    
}
