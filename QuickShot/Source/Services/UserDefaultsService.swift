//
//  UserDefaultsService.swift
//  QuickShot
//
//  Created by Martin Vidovic on 14/07/2020.
//  Copyright © 2020 Martin Vidovic. All rights reserved.
//

import Foundation

final class UserDefaultsService {
    
    private let userDefaults: UserDefaults
    private let bookmarkKey: String
    
    init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
        self.bookmarkKey = "MacOSBookmarkKEY"
    }
    
    /// Load data for access to directory outside of Sandbox
    /// - Returns: Optional Data
    func getBookmark() -> Data? {
        return userDefaults.data(forKey: bookmarkKey)
    }
    
    /// Save data for access to directory outside of Sandbox
    /// - Parameter bookmark: Data
    func setBookmark(bookmark: Data) {
        userDefaults.set(bookmark, forKey: bookmarkKey)
    }
}
