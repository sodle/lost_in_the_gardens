//
//  ParkData.swift
//  Lost in the Gardens
//
//  Created by Scott Odle on 8/29/25.
//

import CoreLocation
import SwiftUI

struct ParkExhibit : Decodable, Identifiable {
    enum CodingKeys : String, CodingKey {
        case name
        case _coordinate = "coordinate"
        case monogram
    }
    
    var id: String { name }
    
    let name: String
    private let _coordinate: ParkCoordinate
    let monogram: String?
    
    var coordinate: CLLocationCoordinate2D {
        _coordinate.coordinate
    }
}

struct ParkMarkerColor : Decodable {
    let red: Double
    let green: Double
    let blue: Double
    
    var color: Color {
        .init(red: red, green: green, blue: blue)
    }
}

struct ParkExhibitCategory : Decodable, Identifiable {
    enum CodingKeys: String, CodingKey {
        case name
        case exhibits
        case _color = "color"
    }
    
    var id: String { name }
    
    let name: String
    let exhibits: [ParkExhibit]
    private let _color: ParkMarkerColor
    
    var color: Color {
        _color.color
    }
}

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
        case categories
    }
    
    let name: String
    private let _center: ParkCoordinate
    private let _bounds: [ParkCoordinate]
    let categories: [ParkExhibitCategory]
    
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
