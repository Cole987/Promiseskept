//
//  Promise.swift
//  PromisTracker
//
//  Created by Yanis Racouët on 7/12/25.
//

import Foundation

struct Promise: Identifiable, Codable {
    var id = UUID()
    var title: String
    var notes: String
    var startDate: Date
    var endDate: Date
    var progress: Double
    var completed: Bool
    var pinned: Bool
    var files: [URL] = []
    var priority: Int = 0
    var failed: Bool = false
}
