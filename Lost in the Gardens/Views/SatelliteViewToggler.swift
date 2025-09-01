//
//  SatelliteViewToggler.swift
//  Lost in the Gardens
//
//  Created by Scott Odle on 8/31/25.
//

import SwiftUI

struct SatelliteViewToggler: View {
    @Binding var isSatelliteViewActive: Bool
    
    func toggle() {
        isSatelliteViewActive.toggle()
    }
    
    private var buttonStyle: some PrimitiveButtonStyle {
        if #available(iOS 26.0, macOS 26.0, *) {
            return .glassProminent
        } else {
            return .borderedProminent
        }
    }
    
    private var imageName: String {
        isSatelliteViewActive ? "globe.americas.fill" : "map.fill"
    }
    
    var body: some View {
        Button(action: toggle) {
            Image(systemName: imageName)
        }
        .buttonStyle(buttonStyle)
        .buttonBorderShape(.roundedRectangle)
        .tint(.accent)
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    Group {
        SatelliteViewToggler(isSatelliteViewActive: .constant(false))
        SatelliteViewToggler(isSatelliteViewActive: .constant(true))
    }
}
