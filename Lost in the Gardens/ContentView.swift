//
//  ContentView.swift
//  Lost in the Gardens
//
//  Created by Scott Odle on 8/28/25.
//

import SwiftUI
import MapKit

let yorkStreetData = ParkDataFile("YorkStreet")
let yorkStreetCategories = ParkCategoryFile("YorkStreet")

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

struct ContentView: View {
    @State var camera: MapCameraPosition = MapCameraPosition.camera(initialCamera)
    @State var selectedMarker: ParkDataMarker?
    @State var isSatelliteViewActive: Bool = false
    @State var isExhibitListOpen: Bool = false
    
    @Namespace private var mapScope
    @ObservedObject private var locationManager = LocationManager(park: yorkStreetData)
    
    private var mapStyle: MapStyle {
        isSatelliteViewActive ? .imagery : .standard(pointsOfInterest: .excludingAll)
    }
    
    private func onSelectExhibit(_ marker: ParkDataMarker) {
        selectedMarker = marker
        camera = MapCameraPosition.camera(MapCamera(centerCoordinate: marker.marker.coordinate, distance: 500))
        isExhibitListOpen = false
    }
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Map (
                position: $camera,
                bounds: bounds,
                interactionModes: [.pan, .zoom, .rotate],
                selection: $selectedMarker,
                scope: mapScope,
            ) {
                parkShape
                    .stroke(.blue, lineWidth: 3)
                    .foregroundStyle(.clear)
                ForEach(yorkStreetData.parkMarkers) { marker in
                    marker
                }
                UserAnnotation()
            }
            .mapControlVisibility(.hidden)
            .mapStyle(mapStyle)
            
            NavigationOverlay(
                mapScope: mapScope,
                isSatelliteViewActive: $isSatelliteViewActive,
                inPark: $locationManager.inPark,
                isExhibitListOpen: $isExhibitListOpen
            )
        }
        .mapScope(mapScope)
        .onAppear {
            locationManager.checkLocationAuthorization()
        }
        .sheet(isPresented: $isExhibitListOpen) {
            ExhibitList(
                onSelectExhibit: onSelectExhibit,
                parkData: yorkStreetData,
                parkCategories: yorkStreetCategories,
            ).toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") {
                        isExhibitListOpen = false
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
