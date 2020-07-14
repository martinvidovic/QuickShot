//
//  DependencyContainer.swift
//  QuickShot
//
//  Created by Martin Vidovic on 14/07/2020.
//  Copyright © 2020 Martin Vidovic. All rights reserved.
//

import Foundation

final class DependencyContainer: Component {
    private let userDefaults: UserDefaults
    private let fileManager: FileManager
    init() {
        self.userDefaults = UserDefaults.standard
        self.fileManager = FileManager.default
    }
    
    lazy var userDefaultsService: UserDefaultsService = {
        return UserDefaultsService(userDefaults: userDefaults)
    }()
    
    lazy var fileManagerService: FileManagerService = {
        return FileManagerService(fileManager: fileManager)
    }()
}
