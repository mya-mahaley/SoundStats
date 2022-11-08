//
//  TrackItem.swift
//  SoundStats
//
//  Created by Evelyn Vo on 11/1/22.
//

import Foundation

struct TrackItem: Codable {
    let items: [Track]
}

struct Track: Codable {
    let name: String
    let id: String
    var artists: [Artist]
}

