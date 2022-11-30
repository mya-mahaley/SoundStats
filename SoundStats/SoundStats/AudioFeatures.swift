//
//  AudioFeatures.swift
//  SoundStats
//
//  Created by Evelyn Vo on 11/28/22.
//

import Foundation

struct AudioFeatures: Codable {
    let valence: Double
    let liveness: Double
    let danceability: Double
    let energy: Double
}
