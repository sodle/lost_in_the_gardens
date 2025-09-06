//
//  MapView.swift
//  Lost in the Gardens
//
//  Created by Scott Odle on 9/5/25.
//

import SwiftUI
import MapKit

struct MapView: View {
    let parkData: ParkDataFile
    
    @State var camera = MapCameraPosition.automatic
    @State var selectedMarker: ParkDataMarker?
    @State var isSatelliteViewActive = false
    
    @ObservedObject var locationManager: LocationManager
    
    private var mapStyle: MapStyle {
        isSatelliteViewActive ? .imagery : .standard(pointsOfInterest: .excludingAll)
    }
    
    private func onSelectExhibit(_ marker: ParkDataMarker) {
        selectedMarker = marker
        camera = MapCameraPosition.item(marker.position)
    }
    
    private var bounds: MapCameraBounds {
        let region = MKCoordinateRegion(
            center: parkData.parkCenter.coordinate,
            latitudinalMeters: 1000,
            longitudinalMeters: 1000,
        )
        return MapCameraBounds(
            centerCoordinateBounds: region,
            minimumDistance: 10,
            maximumDistance: 2000,
        )
    }
    
    init(withParkData parkData: ParkDataFile) {
        self.parkData = parkData
        self.locationManager = .init(park: parkData)
    }
    
    var body: some View {
        let parkShape = MapPolygon(parkData.parkBounds)
        
        Map (
            position: $camera,
            bounds: bounds,
            interactionModes: [.pan, .zoom, .rotate],
            selection: $selectedMarker,
        ) {
            parkShape
                .stroke(.blue, lineWidth: 3)
                .foregroundStyle(.clear)
            ForEach(parkData.parkMarkers) { marker in
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
                        parkData: parkData,
                        parkCategories: parkData.categoryFile
                    )
                } label: {
                    Image(systemName: "list.star")
                }

            }
        }
        .toolbarBackground(.visible, for: .navigationBar)
    }
}

#Preview {
    NavigationStack {
        MapView(withParkData: .yorkStreet)
    }
}
