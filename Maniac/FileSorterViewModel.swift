//
//  FileSorterViewModel.swift
//  Maniac
//
//  Created by DEBBIH ATHEMANE on 29/07/2025.
//

import SwiftUI
import CryptoKit

final class FileSorterViewModel: ObservableObject {
    enum SortOption: String, CaseIterable {
        case nom = "Nom"
        case categorie = "Catégorie"
    }

    @Published var files: [ManagedFile] = []
    @Published var selectedCategory: String?
    @Published var duplicateHashes: Set<String> = []
    @Published var sortOption: SortOption = .nom

    let categories = ["images", "documents", "archives", "sons", "videos", "autres"]

    var extensions: Set<String> { Set(files.map { $0.ext }) }

    var filteredFiles: [ManagedFile] {
        let dict: [String: Set<String>] = [
            "images": ["jpg", "jpeg", "png", "gif", "heic"],
            "documents": ["pdf", "docx", "pptx", "txt", "md"],
            "archives": ["zip", "rar", "tar", "gz", "7z"],
            "sons": ["mp3", "wav", "aiff", "caf"],
            "videos": ["mp4", "mov", "avi", "flv", "mkv"]
        ]

        let base: [ManagedFile] = {
            guard let cat = selectedCategory else { return files }
            if let exts = dict[cat] {
                return files.filter { exts.contains($0.ext) }
            } else if cat == "autres" {
                let allExts = dict.values.flatMap { $0 }
                return files.filter { !allExts.contains($0.ext) }
            } else {
                return files.filter { $0.ext == cat }
            }
        }()

        switch sortOption {
        case .nom:
            return base.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        case .categorie:
            return base.sorted { $0.ext < $1.ext }
        }
    }

    func scanUserHome() {
        scanDirectory(FileManager.default.homeDirectoryForCurrentUser)
    }

    func selectDirectory() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.begin { response in
            if response == .OK, let url = panel.url {
                self.scanDirectory(url)
            }
        }
    }

    func scanDirectory(_ root: URL) {
        var result: [ManagedFile] = []
        let keys: [URLResourceKey] = [.isRegularFileKey]
        if let enumerator = FileManager.default.enumerator(
            at: root,
            includingPropertiesForKeys: keys,
            options: [.skipsHiddenFiles, .skipsPackageDescendants]
        ) {
            for case let fileURL as URL in enumerator {
                if let resource = try? fileURL.resourceValues(forKeys: Set(keys)),
                   resource.isRegularFile == true {
                    let hash = computeHash(for: fileURL)
                    result.append(ManagedFile(url: fileURL, hash: hash))
                }
            }
        }
        DispatchQueue.main.async {
            self.files = result
            self.findDuplicates()
        }
    }

    func computeHash(for url: URL) -> String? {
        guard let data = try? Data(contentsOf: url) else { return nil }
        let digest = SHA256.hash( data: data)
        return digest.map { String(format: "%02x", $0) }.joined()
    }

    func findDuplicates() {
        let groups = Dictionary(grouping: files) { $0.hash }
        duplicateHashes = Set(groups.filter { $0.value.count > 1 }.compactMap { $0.key })
    }

    func removeDuplicates() {
        let groups = Dictionary(grouping: files) { $0.hash }
        for (_, group) in groups where group.count > 1 {
            group.dropFirst().forEach(remove)
        }
        findDuplicates()
    }

    func remove(file: ManagedFile) {
        try? FileManager.default.removeItem(at: file.url)
        files.removeAll { $0 == file }
    }

    func icon(for cat: String) -> String {
        switch cat {
        case "images": return "photo"
        case "documents": return "doc.text"
        case "archives": return "archivebox"
        case "sons": return "waveform"
        case "videos": return "film"
        default: return "circle"
        }
    }
}
