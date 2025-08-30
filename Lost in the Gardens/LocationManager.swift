//
//  LocationManager.swift
//  Lost in the Gardens
//
//  Created by Scott Odle on 8/29/25.
//
import Foundation
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
        lastLocation = locations.last?.coordinate
    }
}

