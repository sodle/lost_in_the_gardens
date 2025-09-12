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

struct ParkCategoryFile {
    static let yorkStreet = ParkCategoryFile(fromLocalFile: "YorkStreet")
    
    private let categories: [String: ParkCategory]
    
    init(fromLocalFile filename: String) {
        let data = try! Data(contentsOf: Bundle.main.url(forResource: filename, withExtension: "json")!)
        self.init(fromData: data)
    }
    
    init(fromData categoryData: Data) {
        self.categories = try! JSONDecoder().decode([String: ParkCategory].self, from: categoryData)
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
    let categoryFile: ParkCategoryFile
    
    var body: some MapContent {
        let categoryData = categoryFile.getCategory(properties.category)
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
    
    var position: MKMapItem {
        if #available(iOS 26.0, *) {
            MKMapItem(location: CLLocation(latitude: marker.coordinate.latitude, longitude: marker.coordinate.longitude), address: nil)
        } else {
            MKMapItem(placemark: MKPlacemark(coordinate: marker.coordinate))
        }
    }
}

struct ParkDataFile {
    static let yorkStreet = ParkDataFile(fromLocalFile: "YorkStreet", withCategories: .yorkStreet)
    
    let parkCenter: MKPointAnnotation
    let parkBounds: MKPolygon
    let parkMarkers: [ParkDataMarker]
    let categoryFile: ParkCategoryFile
    
    func getCategory(_ category: String) -> [ParkDataMarker] {
        parkMarkers.filter { $0.properties.category == category }
    }
    
    init(fromLocalFile filename: String, withCategories categoryFile: ParkCategoryFile) {
        let data = try! Data(contentsOf: Bundle.main.url(forResource: filename, withExtension: "geojson")!)
        self.init(fromData: data, withCategories: categoryFile)
    }
    
    init(fromData parkData: Data, withCategories categoryFile: ParkCategoryFile) {
        self.categoryFile = categoryFile
        
        let geoDecoder = MKGeoJSONDecoder()
        let jsonDecoder = JSONDecoder()
        
        let jsonObjects = try! geoDecoder.decode(parkData)
        
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
                        markers.append(ParkDataMarker(properties: properties, marker: point, categoryFile: categoryFile))
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
            fatalError("shapefile did not contain a feature for the center of the park")
        }
        self.parkCenter = center
        
        guard let bounds else {
            fatalError("shapefile did not contain a feature for the boundaries of the park")
        }
        self.parkBounds = bounds
        
        self.parkMarkers = markers
    }
}

struct DataFileManifest: Decodable {
    let url: String
    let effectiveDate: String
    let sha256: String
    
    func load(fromBaseUrl baseUrl: URL, withUrlSession urlSession: URLSession) async throws -> Data {
        let dataUrl = baseUrl.appendingPathComponent(url)
        let (data, _) = try await urlSession.data(from: dataUrl)
        return data
    }
}

struct DataLocationManifest: Decodable {
    let shapeFile: DataFileManifest
    let categoryFile: DataFileManifest
}

struct DataPlatformManifest: Decodable {
    let YorkStreet: DataLocationManifest
}

struct DataManifest: Decodable {
    let iOS: DataPlatformManifest
    
    init(fromJson json: Data) {
        self = try! JSONDecoder().decode(DataManifest.self, from: json)
    }
}

struct DataManager {
    private let baseURL: URL = URL(string: "https://lostinthegardens.com/")!
    private let urlSession: URLSession
    
    private let manifest: DataManifest
    
    init () async throws {
        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.timeoutIntervalForRequest = 1
        sessionConfiguration.timeoutIntervalForResource = 2
        urlSession = URLSession(configuration: sessionConfiguration)
        
        let dataManifestUrl = self.baseURL.appendingPathComponent("/api")
        let (manifestData, _) = try await urlSession.data(from: dataManifestUrl)
        
        self.manifest = DataManifest(fromJson: manifestData)
    }
    
    func loadYorkStreetData() async throws -> ParkDataFile {
        let categoryData = try await manifest.iOS.YorkStreet.categoryFile.load(fromBaseUrl: baseURL, withUrlSession: urlSession)
        let categoryFile = ParkCategoryFile(fromData: categoryData)
        
        let shapeData = try await manifest.iOS.YorkStreet.shapeFile.load(fromBaseUrl: baseURL, withUrlSession: urlSession)
        return ParkDataFile(fromData: shapeData, withCategories: categoryFile)
    }
}
