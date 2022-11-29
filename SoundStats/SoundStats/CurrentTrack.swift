//
//  CurrentTrack.swift
//  SoundStats
//
//  Created by Evelyn Vo on 11/28/22.
//

import Foundation

struct CurrentTrack: Codable {
    let item: CurrentTrackInfo
}

struct CurrentTrackInfo: Codable {
    let href: URL
    let name: String
    let id: String
    var artists: [Artist]
}

