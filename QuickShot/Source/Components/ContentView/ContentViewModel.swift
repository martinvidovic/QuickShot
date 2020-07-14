//
//  ContentViewModel.swift
//  QuickShot
//
//  Created by Martin Vidovic on 14/07/2020.
//  Copyright © 2020 Martin Vidovic. All rights reserved.
//

import Foundation
import Combine
import AppKit

final class ContentViewModel: ObservableObject {
    @Inject var dependencies: DependencyContainer
    @Published var images: [URL]
    
    init() {
        self.images = []
        
        let url: URL?
        if let data = loadAccess() {
             url = restoreFileAccess(with: data)
        } else {
            url = promptForWorkingDirectoryPermission()
        }
        if let url = url {
            loadImages(url: url)
        }
    }
    
    /// Load Screenshots from directory URL
    /// - Parameter url: URL of chosen directory
    private func loadImages(url: URL) {
        do {
            try dependencies
                .fileManagerService
                .loadScreenshots(from: url)
                .forEach { url in images.append(url)}
        } catch {
            print("⚽️", error)
        }
    }
    
    /// Opens window on macOS and granting access to chosen directory
    /// - Returns: Optional directory URL when access is granted
    private func promptForWorkingDirectoryPermission() -> URL? {
        let openPanel = NSOpenPanel()
        openPanel.message = "Choose your directory"
        openPanel.prompt = "Choose"
        openPanel.allowedFileTypes = ["none"]
        openPanel.allowsOtherFileTypes = false
        openPanel.canChooseFiles = false
        openPanel.canChooseDirectories = true

        _ = openPanel.runModal()
        print(openPanel.urls) // this contains the chosen directory
        if let url = openPanel.urls.first {
            saveBookmarkData(for: url)
        }
        return openPanel.urls.first
    }
    
    /// Save access to directory
    /// - Parameter workDir: directory URL
    private func saveBookmarkData(for workDir: URL) {
        do {
            let bookmarkData = try workDir.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
            // Save in UserDefaults
            dependencies.userDefaultsService.setBookmark(bookmark: bookmarkData)
        } catch {
            print("Failed to save bookmark data for \(workDir)", error)
        }
    }
    
    /// Check Access to directory
    /// - Returns: Optional Data
    private func loadAccess() -> Data? {
        return dependencies.userDefaultsService.getBookmark()
    }
    
    /// Restoring access to files in directory during launch
    /// - Parameter bookmarkData: Access Data
    /// - Returns: Optional directory URL
    private func restoreFileAccess(with bookmarkData: Data) -> URL? {
        do {
            var isStale = false
            let url = try URL(resolvingBookmarkData: bookmarkData, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale)
            if isStale {
                // bookmarks could become stale as the OS changes
                print("Bookmark is stale, need to save a new one... ")
                saveBookmarkData(for: url)
            }
            return url
        } catch {
            print("Error resolving bookmark:", error)
            return nil
        }
    }
}
