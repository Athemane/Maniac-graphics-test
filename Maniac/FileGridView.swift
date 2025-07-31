//
//  FileGridView.swift
//  Maniac
//
//  Created by DEBBIH ATHEMANE on 29/07/2025.
//

import SwiftUI

struct FileGridView: View {
    let files: [ManagedFile]
    let removeAction: (ManagedFile) -> Void
    let highlightDuplicates: Set<String>

    private let columns = [GridItem(.adaptive(minimum: 220), spacing: 10)]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(files) { file in
                    HStack(spacing: 12) {
                        Image(nsImage: NSWorkspace.shared.icon(forFile: file.url.path))
                            .resizable()
                            .frame(width: 36, height: 36)
                            .cornerRadius(6)

                        VStack(alignment: .leading) {
                            Text(file.name)
                                .font(.subheadline)
                                .lineLimit(1)
                                .foregroundColor(.white)
                            Text(file.ext.uppercased())
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        Button {
                            removeAction(file)
                        } label: {
                            Image(systemName: "trash")
                                .foregroundColor(.gray)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.vertical, 6)
                    .padding(.horizontal, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(.sRGB, white: 0.1, opacity: 1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(highlightDuplicates.contains(file.hash ?? "") ? Color.red.opacity(0.5) : .clear, lineWidth: 1)
                            )
                    )
                }
            }
            .padding(.horizontal)
        }
        .background(Color.black)
        .scrollContentBackground(.hidden)
    }
}
