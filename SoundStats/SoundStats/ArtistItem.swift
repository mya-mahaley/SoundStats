//
//  ArtistItem.swift
//  SoundStats
//
//  Created by Evelyn Vo on 11/1/22.
//

import Foundation

struct ArtistItem: Codable {
    let items: [Artist]
}

struct Artist: Codable {
    var externalUrls: ExternalURL?
    var followers: Follower?
    var genres: [String]?
    var images: [Images]?
    let name: String
    let id: String
}

struct Follower: Codable {
    let total: Int
}

struct Images: Codable {
    let height: Int
    let width: Int
    let url: String
}

struct ExternalURL: Codable {
    let spotify: String
}
