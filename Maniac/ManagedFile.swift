//
//  ManagedFile.swift
//  Maniac
//
//  Created by DEBBIH ATHEMANE on 29/07/2025.
//

import Foundation

struct ManagedFile: Identifiable, Equatable {
    let id: UUID = UUID()
    let url: URL
    let hash: String?
    var ext: String { url.pathExtension.lowercased() }
    var name: String { url.lastPathComponent }

    static func ==(lhs: ManagedFile, rhs: ManagedFile) -> Bool {
        lhs.url == rhs.url
    }
}
