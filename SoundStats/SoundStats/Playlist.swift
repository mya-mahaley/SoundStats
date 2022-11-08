//
//  Playlist.swift
//  SoundStats
//
//  Created by Evelyn Vo on 11/6/22.
//

import Foundation

struct Playlist: Codable {
    let tracks: PlaylistItem
}

struct PlaylistItem: Codable {
    let items: [PlaylistTrackItem]
}

struct PlaylistTrackItem: Codable {
    let track: Track
}
