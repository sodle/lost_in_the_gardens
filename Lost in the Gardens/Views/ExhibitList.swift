//
//  ExhibitList.swift
//  Lost in the Gardens
//
//  Created by Scott Odle on 8/31/25.
//

import SwiftUI

struct ExhibitListItem: View {
    let marker: ParkDataMarker
    let category: ParkCategory
    let isSearching: Bool
    let onSelect: (ParkDataMarker) -> Void
    
    var body: some View {
        Button {
            onSelect(marker)
        } label: {
            HStack {
                Text(marker.properties.monogram ?? "")
                    .bold()
                    .frame(width: 50, height: 50)
                    .background {
                        Circle().fill(category.color.uiColor)
                    }
                VStack (alignment: .leading) {
                    Text(marker.properties.name)
                    if isSearching {
                        Text(category.name)
                            .font(.footnote)
                    }
                }
                Spacer()
            }
        }.tint(.primary)
    }
}

struct ExhibitList: View {
    let onSelectExhibit: (ParkDataMarker) -> Void
    let parkData: ParkDataFile
    let parkCategories: ParkCategoryFile
    
    @Environment(\.dismiss) var dismiss
    
    @State var searchQuery: String = ""
    @State var searchResults: [ParkDataMarker] = []
    
    var isSearching: Bool {
        return !searchQuery.isEmpty
    }
    
    var body: some View {
        List {
            if isSearching {
                ForEach(searchResults) { marker in
                    let category = parkCategories.getCategory(marker.properties.category)
                    ExhibitListItem(marker: marker, category: category, isSearching: true) { marker in
                        onSelectExhibit(marker)
                        searchQuery = ""
                        dismiss()
                    }
                }
            } else {
                ForEach(parkCategories.categoryKeys, id: \.self) { categoryKey in
                    let category = parkCategories.getCategory(categoryKey)
                    let markers = parkData.getCategory(categoryKey)
                    Section(category.name) {
                        ForEach(markers) { marker in
                            ExhibitListItem(marker: marker, category: category, isSearching: false) { marker in
                                onSelectExhibit(marker)
                                dismiss()
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle(Text("Exhibits"))
        .searchable(
            text: $searchQuery,
            placement: .automatic,
            prompt: "Search for an exhibit...",
        )
        .textInputAutocapitalization(.never)
        .onChange(of: searchQuery) { oldValue, newValue in
            fetchSearchResults(for: newValue)
        }
    }
    
    private func fetchSearchResults(for query: String) {
        searchResults = parkData.parkMarkers.filter { marker in
            marker.properties.name.lowercased().contains(query.lowercased())
        }
    }
}

#Preview {
    NavigationView {
        ExhibitList(
            onSelectExhibit: { marker in
                print("tap on \(marker.properties.name)")
            },
            parkData: .yorkStreet,
            parkCategories: .yorkStreet,
        )
    }
}
