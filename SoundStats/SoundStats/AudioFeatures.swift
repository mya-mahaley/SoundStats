//
//  AudioFeatures.swift
//  SoundStats
//
//  Created by Evelyn Vo on 11/28/22.
//

import Foundation

struct AudioFeatures: Codable {
    let valence: Float
    let liveness: Float
    let danceability: Float
    let energy: Float
}
