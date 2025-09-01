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

struct ContentView: View {
    @State var camera: MapCameraPosition = MapCameraPosition.camera(initialCamera)
    @State var selectedMarker: ParkDataMarker?
    @State var isSatelliteViewActive: Bool = false
    
    @Namespace private var mapScope
    @ObservedObject private var locationManager = LocationManager(park: yorkStreetData)
    
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
            }.mapControlVisibility(.hidden)
                .mapStyle(isSatelliteViewActive ? .imagery : .standard(pointsOfInterest: .excludingAll))
                .onAppear {
                    locationManager.checkLocationAuthorization()
                }
            
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
                        if locationManager.inPark {
                            MapUserLocationButton(scope: mapScope)
                        }
#if os(macOS)
                        MapZoomStepper(scope: mapScope)
#endif
                    }.frame(maxWidth: .infinity, alignment: .trailing)
                }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            }.padding()
        }.mapScope(mapScope)
    }
}

#Preview {
    ContentView()
}
