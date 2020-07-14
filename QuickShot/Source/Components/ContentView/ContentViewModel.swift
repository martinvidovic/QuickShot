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
    @Published var images: [URL]
    let fileManager: FileManager
    let defaults = UserDefaults.standard
    
    init() {
        self.images = []
        self.fileManager = FileManager.default
        
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
    
    func loadImages(url: URL) {
        if !url.startAccessingSecurityScopedResource() {
            print("startAccessingSecurityScopedResource returned false. This directory might not need it, or this URL might not be a security scoped URL, or maybe something's wrong?")
        }
        do {
            try fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
                .sorted(by: { url1, url2 -> Bool in
                    let value1 = try url1.resourceValues(forKeys: [.creationDateKey, .contentModificationDateKey])
                    let value2 = try url2.resourceValues(forKeys: [.creationDateKey, .contentModificationDateKey])

                    if let date1 = value1.creationDate, let date2 = value2.creationDate {
                        return date1.compare(date2) == ComparisonResult.orderedDescending
                    } else {
                        return true
                    }
                })
                .forEach { url in
                    images.append(url)
            }
        } catch let error {
            print("⚽️", error)
        }
    }
    
    private func promptForWorkingDirectoryPermission() -> URL? {
        let openPanel = NSOpenPanel()
        openPanel.message = "Choose your directory"
        openPanel.prompt = "Choose"
        openPanel.allowedFileTypes = ["none"]
        openPanel.allowsOtherFileTypes = false
        openPanel.canChooseFiles = false
        openPanel.canChooseDirectories = true

        _ = openPanel.runModal()
        print(openPanel.urls) // this contains the chosen folder
        if let url = openPanel.urls.first {
            saveBookmarkData(for: url)
        }
        return openPanel.urls.first
    }
    
    private func saveBookmarkData(for workDir: URL) {
        do {
            let bookmarkData = try workDir.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
            // Save in UserDefaults
            defaults.set(bookmarkData, forKey: "URL")
        } catch {
            print("Failed to save bookmark data for \(workDir)", error)
        }
    }
    
    private func loadAccess() -> Data? {
        return defaults.data(forKey: "URL")
    }
    
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
