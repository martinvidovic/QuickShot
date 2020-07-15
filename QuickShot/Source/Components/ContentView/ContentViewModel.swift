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
    @Published var errorMessage: String
    var url: URL?
    var directoryMonitor: DirectoryMonitor?
    private var cancellables: [AnyCancellable]
    
    init() {
        self.images = []
        self.url = nil
        self.directoryMonitor = nil
        self.cancellables = []
        self.errorMessage = ""
        
        if let data = loadAccess() {
            self.url = restoreFileAccess(with: data)
        } else {
            self.url = promptForWorkingDirectoryPermission()
        }
        if let url = url {
            loadImages(url: url)
             
            self.directoryMonitor = DirectoryMonitor(url: url)
            directoryMonitor?.delegate = self
            directoryMonitor?.startMonitoring()
        }
    }
    
    deinit {
        directoryMonitor?.stopMonitoring()
    }
    
    /// Load Screenshots from directory URL
    /// - Parameter url: URL of chosen directory
    func loadImages(url: URL) {
        publishImages(url: url)
            .receive(on: RunLoop.main)
            .catch({ [weak self] error -> Empty<[URL], Never> in
                self?.errorMessage = error.localizedDescription
                return .init()
            })
            .sink { URLs in
                self.images = URLs
        }.store(in: &cancellables)
    }
    
    /// Function that sends [URL] as a success and if there is an error, it sends error in failure
    /// - Parameter url: URL of chosen directory
    /// - Returns: Future<[URL], Error>`
    private func publishImages(url: URL) -> Future<[URL], Error> {
//        catching error and passing data/error in future is really "nice and modern" approach in my opinion
        Future<[URL], Error> { [weak self] emitter in
            do {
                let array = try self?.dependencies
                    .fileManagerService
                    .loadScreenshots(from: url)
                if let result = array {
                    emitter(.success(result))
                }
            } catch {
                emitter(.failure(error))
            }
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

extension ContentViewModel: DirectoryMonitorDelegate {
    func directoryMonitorDidObserveChange(directoryMonitor: DirectoryMonitor) {
        guard let url = url else { return }
        loadImages(url: url)
    }
}
