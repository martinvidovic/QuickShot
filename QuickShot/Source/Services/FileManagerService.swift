//
//  FileManagerService.swift
//  QuickShot
//
//  Created by Martin Vidovic on 14/07/2020.
//  Copyright © 2020 Martin Vidovic. All rights reserved.
//

import Foundation

final class FileManagerService {
    private let fileManager: FileManager
    
    init(fileManager: FileManager) {
        self.fileManager = fileManager
    }
    
    /// Load Screenshots URL from folder
    /// - Parameter url: URL of folder
    /// - Throws: throws an error if folder is not found or something bad happened during loading screenshots
    /// - Returns: array of screenshots URL
    func loadScreenshots(from url: URL) throws -> [URL] {
        if !url.startAccessingSecurityScopedResource() {
            print("startAccessingSecurityScopedResource returned false. This directory might not be a security scoped URL, or maybe something's wrong?")
        }
        
        return try fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
        .sorted(by: { url1, url2 -> Bool in
            let value1 = try url1.resourceValues(forKeys: [.creationDateKey, .contentModificationDateKey])
            let value2 = try url2.resourceValues(forKeys: [.creationDateKey, .contentModificationDateKey])

            if let date1 = value1.creationDate, let date2 = value2.creationDate {
                return date1.compare(date2) == ComparisonResult.orderedDescending
            } else {
                return true
            }
        })
    }
}
