//
//  ContentView.swift
//  Lost in the Gardens
//
//  Created by Scott Odle on 8/28/25.
//

import SwiftUI
import MapKit

let yorkStreetData = ParkDataFile("YorkStreet")
let parkShape = MapPolygon(yorkStreetData.parkBounds)

let region = MKCoordinateRegion(
    center: yorkStreetData.parkCenter.coordinate,
    latitudinalMeters: 1000,
    longitudinalMeters: 1000,
)
let bounds = MapCameraBounds(
    centerCoordinateBounds: region,
    minimumDistance: 10,
    maximumDistance: 2000,
)
let initialCamera = MapCamera(centerCoordinate: yorkStreetData.parkCenter.coordinate, distance: 1000)

enum BaseLayer: String, CaseIterable, Identifiable {
    var id: String { rawValue }
    
    case standard = "Streets"
    case imagery = "Satellite"
    
    func mapStyle() -> MapStyle {
        switch self {
        case .standard:
            return MapStyle.standard(pointsOfInterest: .excludingAll)
        case .imagery:
            return MapStyle.imagery
        }
    }
}

struct MapPicker: View {
    @Binding var baseLayer: BaseLayer
    
    var body: some View {
        HStack {
            Text("Map Style: ")
            Picker("Map Style", selection: $baseLayer) {
                ForEach(BaseLayer.allCases) { baseLayer in
                    Text(baseLayer.rawValue).tag(baseLayer)
                }
            }
        }
    }
}

struct ContentView: View {
    @State var camera: MapCameraPosition = MapCameraPosition.camera(initialCamera)
    @State var baseLayer: BaseLayer = .standard
    @State var selectedMarker: ParkDataMarker?
    
    private var locationManager = LocationManager()
    
    var body: some View {
        VStack {
            Map (
                position: $camera,
                bounds: bounds,
                interactionModes: [.pan, .zoom],
                selection: $selectedMarker,
            ) {
                parkShape
                    .stroke(.blue, lineWidth: 3)
                    .foregroundStyle(.clear)
                ForEach(yorkStreetData.parkMarkers) { marker in
                    marker
                }
            }
            .mapControls {
                MapScaleView()
            }
            .mapControlVisibility(.visible)
            .mapStyle(baseLayer.mapStyle())
            
            MapPicker(baseLayer: $baseLayer)
        }
        .background(Color.background)
    }
}

#Preview {
    ContentView()
}
