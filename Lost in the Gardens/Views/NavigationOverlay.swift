//
//  NavigationOverlay.swift
//  Lost in the Gardens
//
//  Created by Scott Odle on 8/31/25.
//

import SwiftUI
import MapKit

struct NavigationOverlay: View {
    let mapScope: Namespace.ID
    @Binding var isSatelliteViewActive: Bool
    @Binding var inPark: Bool
    
    var body: some View {
        VStack {
            HStack(alignment: .top) {
                VStack {
                    MapScaleView(scope: mapScope)
                }.frame(maxWidth: .infinity, alignment: .leading)
                
                HStack {
                    VStack {
                        SatelliteViewToggler(isSatelliteViewActive: $isSatelliteViewActive)
                        MapCompass(scope: mapScope)
                    }
                }.frame(maxWidth: .infinity, alignment: .trailing)
            }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            
            HStack(alignment: .bottom) {
                VStack(alignment: .trailing) {
                    if inPark {
                        MapUserLocationButton(scope: mapScope)
                    }
#if os(macOS)
                    MapZoomStepper(scope: mapScope)
#endif
                }.frame(maxWidth: .infinity, alignment: .trailing)
            }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
        }.padding()
    }
}

#Preview {
    @Previewable @Namespace var mapScope
    NavigationOverlay(mapScope: mapScope, isSatelliteViewActive: .constant(false), inPark: .constant(true))
}
