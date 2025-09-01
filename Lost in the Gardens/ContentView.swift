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
    
    @ObservedObject private var locationManager = LocationManager(park: yorkStreetData)
    
    @State private var navigationPath = [Int]()
    
    private var mapStyle: MapStyle {
        isSatelliteViewActive ? .imagery : .standard(pointsOfInterest: .excludingAll)
    }
    
    private func onSelectExhibit(_ marker: ParkDataMarker) {
        selectedMarker = marker
        camera = MapCameraPosition.camera(MapCamera(centerCoordinate: marker.marker.coordinate, distance: 500))
    }
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            Map (
                position: $camera,
                bounds: bounds,
                interactionModes: [.pan, .zoom, .rotate],
                selection: $selectedMarker,
            ) {
                parkShape
                    .stroke(.blue, lineWidth: 3)
                    .foregroundStyle(.clear)
                ForEach(yorkStreetData.parkMarkers) { marker in
                    marker
                }
                UserAnnotation()
            }
            .mapControls {
                MapScaleView()
                MapCompass()
                if locationManager.inPark {
                    MapUserLocationButton()
                }
#if os(macOS)
                MapZoomStepper()
#endif
            }
            .mapStyle(mapStyle)
            .onAppear {
                locationManager.checkLocationAuthorization()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Picker(selection: $isSatelliteViewActive, label: Text("Map Style")) {
                        Image(systemName: "map").tag(false)
                        Image(systemName: "globe.americas").tag(true)
                    }
                    .pickerStyle(.segmented)
                    .fixedSize()
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink {
                        ExhibitList(
                            onSelectExhibit: onSelectExhibit,
                            parkData: yorkStreetData,
                            parkCategories: yorkStreetCategories
                        )
                        .navigationTitle(Text("Destinations"))
                    } label: {
                        Image(systemName: "list.star")
                    }

                }
            }
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
}

#Preview {
    ContentView()
}
