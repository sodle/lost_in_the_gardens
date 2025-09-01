//
//  ParkData.swift
//  Lost in the Gardens
//
//  Created by Scott Odle on 8/29/25.
//

import Foundation
import CoreLocation
import SwiftUI
import MapKit

let categoriesPlistFilename = "Categories"

class ParkCategoryColor: Decodable {
    let red: Double
    let green: Double
    let blue: Double
    
    init(red: Double, green: Double, blue: Double) {
        self.red = red
        self.green = green
        self.blue = blue
    }
    
    var uiColor: Color {
        Color(red: red, green: green, blue: blue)
    }
}

class ParkCategory: Decodable, Identifiable, Comparable {
    static func < (lhs: ParkCategory, rhs: ParkCategory) -> Bool {
        lhs.index < rhs.index
    }
    
    static func == (lhs: ParkCategory, rhs: ParkCategory) -> Bool {
        lhs.index == rhs.index
    }
    
    let index: Int
    let name: String
    let color: ParkCategoryColor
    
    init(index: Int, name: String, color: ParkCategoryColor) {
        self.index = index
        self.name = name
        self.color = color
    }
    
    static let unknown = ParkCategory(index: -1, name: "Unknown", color: ParkCategoryColor(red: 0, green: 0, blue: 0))
}

class ParkCategoryFile {
    private let categories: [String: ParkCategory]
    static let shared = ParkCategoryFile(categoriesPlistFilename)

    init(_ filename: String) {
        guard let categoriesUrl = Bundle.main.url(forResource: categoriesPlistFilename, withExtension: "plist") else {
            fatalError("Couldn't find \(categoriesPlistFilename).plist in main bundle.")
        }
        
        let categoriesData = try! Data(contentsOf: categoriesUrl)
        self.categories = try! PropertyListDecoder().decode([String: ParkCategory].self, from: categoriesData)
    }
    
    func getCategory(_ name: String) -> ParkCategory {
        categories[name] ?? ParkCategory.unknown
    }
    
    var categoriesList: [ParkCategory] {
        categories.values.sorted()
    }
    
    var categoryKeys: [String] {
        categories.keys.sorted()
    }
}

struct ParkDataProperties: Decodable {
    let name: String
    let category: String
    let monogram: String?
    let iconName: String?
    
    var sortKey: String {
        guard let monogram, !monogram.isEmpty else { return name }
        if let number = Int(monogram) {
            return String(format: "%02d", number)
        }
        return monogram
    }
}

struct ParkDataMarker: Identifiable, Hashable, MapContent, Comparable {
    static func < (lhs: ParkDataMarker, rhs: ParkDataMarker) -> Bool {
        lhs.properties.sortKey < rhs.properties.sortKey
    }
    
    static func == (lhs: ParkDataMarker, rhs: ParkDataMarker) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    var id: String { properties.name }
    
    let properties: ParkDataProperties
    let marker: MKPointAnnotation
    
    var body: some MapContent {
        let categoryData = ParkCategoryFile.shared.getCategory(properties.category)
        if let monogram = properties.monogram {
            Marker(properties.name, monogram: Text(monogram), coordinate: marker.coordinate)
                .tint(categoryData.color.uiColor)
                .tag(self)
        } else if let iconName = properties.iconName {
            Marker(properties.name, systemImage: iconName, coordinate: marker.coordinate)
                .tint(categoryData.color.uiColor)
                .tag(self)
        } else {
            Marker(properties.name, coordinate: marker.coordinate)
                .tint(categoryData.color.uiColor)
                .tag(self)
        }
    }
}

struct ParkDataFile {
    let parkCenter: MKPointAnnotation
    let parkBounds: MKPolygon
    let parkMarkers: [ParkDataMarker]
    
    func getCategory(_ category: String) -> [ParkDataMarker] {
        parkMarkers.filter { $0.properties.category == category }
    }
    
    init(_ filename: String) {
        let geoDecoder = MKGeoJSONDecoder()
        let jsonDecoder = JSONDecoder()
        
        guard let jsonUrl = Bundle.main.url(forResource: filename, withExtension: "geojson") else {
            fatalError("Couldn't find \(filename).geojson in main bundle.")
        }
        
        let data = try! Data(contentsOf: jsonUrl)
        let jsonObjects = try! geoDecoder.decode(data)
        
        var center: MKPointAnnotation?
        var bounds: MKPolygon?
        var markers = [ParkDataMarker]()
        
        for object in jsonObjects {
            guard let feature = object as? MKGeoJSONFeature else {
                print("Skipping non-feature JSON object")
                continue
            }
            
            guard let propertiesJson = feature.properties else {
                print("Skipping feature with no properties")
                continue
            }
            guard let properties = try? jsonDecoder.decode(ParkDataProperties.self, from: propertiesJson) else {
                let props = String(data: propertiesJson, encoding: .utf8) ?? "<undecodable text>"
                print("Skipping feature with invalid properties: \(props)")
                continue
            }
            
            for geometry in feature.geometry {
                if let point = geometry as? MKPointAnnotation {
                    if properties.category == "park-geometry" {
                        center = point
                    } else {
                        markers.append(ParkDataMarker(properties: properties, marker: point))
                    }
                } else if let polygon = geometry as? MKPolygon {
                    if properties.category == "park-geometry" {
                        bounds = polygon
                    } else {
                        print("Skipping non-park-geometry polygon")
                    }
                } else {
                    print("Skipping unrecognized feature")
                }
            }
        }
        
        guard let center else {
            fatalError("\(filename).geojson did not contain a feature for the center of the park")
        }
        self.parkCenter = center
        
        guard let bounds else {
            fatalError("\(filename).geojson did not contain a feature for the boundaries of the park")
        }
        self.parkBounds = bounds
        
        self.parkMarkers = markers
    }
}
