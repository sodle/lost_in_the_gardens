//
//  LocationManager.swift
//  Lost in the Gardens
//
//  Created by Scott Odle on 8/29/25.
//
import Foundation
import CoreLocation
import MapKit

final class LocationManager : NSObject, CLLocationManagerDelegate, ObservableObject {
    let park: ParkDataFile
    
    @Published var lastLocation: CLLocationCoordinate2D?
    @Published var bearing: CLLocationDirection?
    @Published var inPark: Bool = false

    private let manager = CLLocationManager()
    
    init(park: ParkDataFile) {
        self.park = park
    }
    
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
            manager.requestWhenInUseAuthorization()
        @unknown default:
            print("location status unknown: \(manager.authorizationStatus)")
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        //Trigged every time authorization status changes
        checkLocationAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation = locations.last else {
            inPark = false
            return
        }
        
        lastLocation = currentLocation.coordinate
        bearing = currentLocation.course
        inPark = park.parkBounds.boundingMapRect.contains(MKMapPoint(currentLocation.coordinate))
    }
}

