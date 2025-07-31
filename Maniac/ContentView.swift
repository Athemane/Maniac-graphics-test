//
//  ContentView.swift
//  Maniac
//
//  Created by DEBBIH ATHEMANE on 29/07/2025.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var vm = FileSorterViewModel()

    init() {
        NSApp.appearance = NSAppearance(named: .darkAqua)
    }

    var body: some View {
        HStack(spacing: 0) {
            List(selection: $vm.selectedCategory) {
                Section("Catégories") {
                    ForEach(vm.categories, id: \.self) { cat in
                        Label(cat.capitalized, systemImage: vm.icon(for: cat))
                            .tag(cat)
                            .foregroundColor(.white)
                    }
                }

                Section("Extensions") {
                    ForEach(vm.extensions.sorted(), id: \.self) { ext in
                        Label(".\(ext)", systemImage: "doc")
                            .tag(ext)
                            .foregroundColor(.gray)
                    }
                }
            }
            .listStyle(SidebarListStyle())
            .scrollContentBackground(.hidden)
            .background(Color.black)
            .frame(minWidth: 180)

            VStack(spacing: 0) {
                HStack {
                    Text("Tri & Doublons")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.leading, 16)

                    Spacer()

                    Menu {
                        ForEach(FileSorterViewModel.SortOption.allCases, id: \.self) { option in
                            Button(option.rawValue) {
                                vm.sortOption = option
                            }
                        }
                    } label: {
                        Image(systemName: "arrow.up.arrow.down")
                            .foregroundColor(.gray)
                    }

                    Button {
                        vm.selectDirectory()
                    } label: {
                        Image(systemName: "folder.badge.plus")
                            .foregroundColor(.gray)
                    }

                    Button {
                        vm.removeDuplicates()
                    } label: {
                        Image(systemName: "trash.circle")
                            .foregroundColor(vm.duplicateHashes.isEmpty ? .gray.opacity(0.3) : .gray)
                    }
                    .disabled(vm.duplicateHashes.isEmpty)
                    .padding(.trailing, 16)
                }
                .frame(height: 44)
                .background(Color.black)

                Divider().background(Color.gray.opacity(0.2))

                FileGridView(
                    files: vm.filteredFiles,
                    removeAction: vm.remove,
                    highlightDuplicates: vm.duplicateHashes
                )
            }
            .background(Color.black)
        }
        .background(Color.black)
        .ignoresSafeArea()
        .preferredColorScheme(.dark)
        .onAppear { vm.scanUserHome() }
    }
}
