//
//  ContentView.swift
//  Lost in the Gardens
//
//  Created by Scott Odle on 8/28/25.
//

import SwiftUI
import MapKit

let yorkStreet = ParkData.load(plistName: "YorkStreet")

let parkShape = MapPolygon(coordinates: yorkStreet.bounds)

let region = MKCoordinateRegion(
    center: yorkStreet.center,
    latitudinalMeters: 1000,
    longitudinalMeters: 1000,
)
let bounds = MapCameraBounds(
    centerCoordinateBounds: region,
    minimumDistance: 10,
    maximumDistance: 2000,
)
let initialCamera = MapCamera(centerCoordinate: yorkStreet.center, distance: 1000)

enum BaseLayer: Hashable, Equatable {
    case standard, hybrid, imagery
    
    func mapStyle() -> MapStyle {
        switch self {
        case .standard:
            return MapStyle.standard
        case .hybrid:
            return MapStyle.hybrid
        case .imagery:
            return MapStyle.imagery
        }
    }
}

struct ContentView: View {
    @State var camera: MapCameraPosition = MapCameraPosition.camera(initialCamera)
    @State var baseLayer: BaseLayer = .standard
    
    private var locationManager = LocationManager()
    
    var body: some View {
        VStack {
            Map(
                initialPosition: camera,
                bounds: bounds,
                interactionModes: [.pan, .zoom]
            ) {
                parkShape
                    .stroke(.blue, lineWidth: 3)
                    .foregroundStyle(.clear)
            }
            .mapControls {
                MapScaleView()
            }
            .mapControlVisibility(.visible)
            .mapStyle(baseLayer.mapStyle())
            
            HStack {
                Text("Map Style: ")
                Picker("Map Style", selection: $baseLayer) {
                    Text("Streets").tag(BaseLayer.standard)
                    Text("Hybrid").tag(BaseLayer.hybrid)
                    Text("Satellite").tag(BaseLayer.imagery)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
