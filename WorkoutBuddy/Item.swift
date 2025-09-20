//
//  Item.swift
//  WorkoutBuddy
//
//  Created by Matthew Strauss on 2025/09/20.
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
