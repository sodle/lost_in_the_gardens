//
//  Item.swift
//  Lost in the Gardens
//
//  Created by Scott Odle on 8/28/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
