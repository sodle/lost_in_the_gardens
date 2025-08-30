//
//  ParkData.swift
//  Lost in the Gardens
//
//  Created by Scott Odle on 8/29/25.
//

import CoreLocation

struct ParkCoordinate : Decodable {
    let latitude: Double
    let longitude: Double
    
    var coordinate: CLLocationCoordinate2D {
        .init(latitude: latitude, longitude: longitude)
    }
}

struct ParkData : Decodable {
    enum CodingKeys : String, CodingKey {
        case name
        case _center = "center"
        case _bounds = "bounds"
    }
    
    let name: String
    private let _center: ParkCoordinate
    private let _bounds: [ParkCoordinate]
    
    static func load(plistName: String) -> ParkData {
        let path = Bundle.main.path(forResource: plistName, ofType: "plist")!
        let data = try! Data(contentsOf: URL(fileURLWithPath: path))
        return try! PropertyListDecoder().decode(ParkData.self, from: data)
    }
    
    var center: CLLocationCoordinate2D {
        _center.coordinate
    }
    
    var bounds: [CLLocationCoordinate2D] {
        _bounds.map(\.coordinate)
    }
}
