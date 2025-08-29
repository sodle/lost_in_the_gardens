//
//  ContentView.swift
//  Lost in the Gardens
//
//  Created by Scott Odle on 8/28/25.
//

import SwiftUI
import MapKit
import CoreLocation

final class LocationManager : NSObject, CLLocationManagerDelegate, ObservableObject {
    @Published var lastLocation: CLLocationCoordinate2D?
    private let manager = CLLocationManager()
    
    func checkLocationAuthorization() {
        manager.delegate = self
        manager.startUpdatingLocation()
        
        switch manager.authorizationStatus {
        case .authorizedAlways:
            print("location always authorized")
            lastLocation = manager.location?.coordinate
        case .authorizedWhenInUse:
            print("location when in use authorized")
            lastLocation = manager.location?.coordinate
        case .restricted, .denied:
            print("location access not allowed")
        case .notDetermined:
            print("requesting location access")
            manager.requestAlwaysAuthorization()
        @unknown default:
            print("location status unknown: \(manager.authorizationStatus)")
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        //Trigged every time authorization status changes
        checkLocationAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lastLocation = locations.last?.coordinate
    }
}

let parkCenter = CLLocationCoordinate2D(
    latitude: 39.73186, longitude: -104.96128515747814
)

let parkCorners = [
    (39.733476786818365, -104.95863799172017),
    (39.732935699862075, -104.958623627187),
    (39.73265653359262, -104.95869692709704),
    (39.732261940879525, -104.95899710768099),
    (39.73184587128658, -104.95922398835492),
    (39.731131836306055, -104.95924842171),
    (39.73115867985941, -104.95985925429365),
    (39.73098688093724, -104.95989415901272),
    (39.730782869161054, -104.96004424930472),
    (39.730490272270266, -104.96017688723715),
    (39.73050906293361, -104.96068649613552),
    (39.73101104018654, -104.96069696755123),
    (39.731036752257566, -104.96410323857782),
    (39.732845986879504, -104.96414512424654),
    (39.73285135545752, -104.96100369953064),
    (39.73345531782102, -104.96105605647185),
]
let parkShape = MapPolygon(coordinates: parkCorners.map { (lat, lon) -> CLLocationCoordinate2D in
    CLLocationCoordinate2D(latitude: lat, longitude: lon)
})

let region = MKCoordinateRegion(
    center: parkCenter,
    latitudinalMeters: 1000,
    longitudinalMeters: 1000,
)
let bounds = MapCameraBounds(
    centerCoordinateBounds: region,
    minimumDistance: 10,
    maximumDistance: 2000,
)
let initialCamera = MapCamera(centerCoordinate: parkCenter, distance: 1000)

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
