//
//  Track.swift
//  FastTrackA
//
//  Created by Weerawut on 3/1/2569 BE.
//

import Foundation

struct Track: Decodable, Identifiable, Equatable {
    let trackId: Int
    let artistName: String
    let trackName: String
    let previewUrl: URL
    let artworkUrl100: String
    
    var id: Int {
        trackId
    }
    
    var artworkURL: URL? {
        let replacedString = artworkUrl100.replacingOccurrences(of: "100x100", with: "300x300")
        return URL(string: replacedString)
    }
}

struct SearchResult: Decodable {
    let results: [Track]
}
