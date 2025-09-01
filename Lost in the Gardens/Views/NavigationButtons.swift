//
//  SatelliteViewToggler.swift
//  Lost in the Gardens
//
//  Created by Scott Odle on 8/31/25.
//

import SwiftUI

func defaultButtonStyle() -> some PrimitiveButtonStyle {
    if #available(iOS 26.0, macOS 26.0, *) {
        return .glassProminent
    } else {
        return .borderedProminent
    }
}

struct SatelliteViewToggler: View {
    @Binding var isSatelliteViewActive: Bool
    
    private func toggle() {
        isSatelliteViewActive.toggle()
    }
    
    private var imageName: String {
        isSatelliteViewActive ? "globe.americas.fill" : "map.fill"
    }
    
    var body: some View {
        Button(action: toggle) {
            Image(systemName: imageName)
        }
        .buttonStyle(defaultButtonStyle())
        .buttonBorderShape(.roundedRectangle)
        .tint(.accent)
    }
}

struct ExhibitListButton: View {
    @Binding var isExhibitListOpen: Bool
    
    private func toggle() {
        isExhibitListOpen.toggle()
    }
    
    var body: some View {
        Button(action: toggle) {
            Image(systemName: "list.star")
        }
        .buttonStyle(defaultButtonStyle())
        .buttonBorderShape(.roundedRectangle)
        .tint(.accent)
    }
}

#Preview {
    Group {
        SatelliteViewToggler(isSatelliteViewActive: .constant(false))
        SatelliteViewToggler(isSatelliteViewActive: .constant(true))
        ExhibitListButton(isExhibitListOpen: .constant(false))
    }
}
