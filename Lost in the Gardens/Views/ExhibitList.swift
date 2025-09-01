//
//  ExhibitList.swift
//  Lost in the Gardens
//
//  Created by Scott Odle on 8/31/25.
//

import SwiftUI

struct ExhibitList: View {
    let onSelectExhibit: (ParkDataMarker) -> Void
    let parkData: ParkDataFile
    let parkCategories: ParkCategoryFile
    
    var body: some View {
        List {
            ForEach(parkCategories.categoryKeys, id: \.self) { categoryKey in
                let category = parkCategories.getCategory(categoryKey)
                let markers = parkData.getCategory(categoryKey)
                Section(category.name) {
                    ForEach(markers) { marker in
                        Button(action: {
                            onSelectExhibit(marker)
                        }, label: {
                            HStack {
                                Text(marker.properties.monogram ?? "")
                                    .bold()
                                    .frame(width: 50, height: 50)
                                    .background {
                                        Circle()
                                            .fill(category.color.uiColor)
                                    }
                                Text(marker.properties.name)
                                Spacer()
                            }
                        }).tint(.primary)
                    }
                }
            }
        }
    }
}

#Preview {
    ExhibitList(
        onSelectExhibit: { marker in
            print("tap on \(marker.properties.name)")
        },
        parkData: .init("YorkStreet"),
        parkCategories: .init("YorkStreet"),
    )
}
