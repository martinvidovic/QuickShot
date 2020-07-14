//
//  Array+extension.swift
//  QuickShot
//
//  Created by Martin Vidovic on 14/07/2020.
//  Copyright © 2020 Martin Vidovic. All rights reserved.
//

import Foundation

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            return Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}

