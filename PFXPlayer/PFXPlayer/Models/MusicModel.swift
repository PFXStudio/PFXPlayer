//
//  MusicModel.swift
//  PFXPlayer
//
//  Created by succorer on 21/01/2020.
//  Copyright © 2020 pfxstudio. All rights reserved.
//

import Foundation

public struct MusicModel : Codable {
    var singer = ""
    var album = ""
    var title = ""
    var duration = 0
    var image = ""
    var file = ""
    var lyrics = ""
    var lyricsSyncs = [LyricsCellModel]()

    var data: Data?
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        
        if let singer = try container.decodeIfPresent(String.self, forKey: .singer) {
            self.singer = singer
        }
        
        if let album = try container.decodeIfPresent(String.self, forKey: .album) {
            self.album = album
        }
        
        if let title = try container.decodeIfPresent(String.self, forKey: .title) {
            self.title = title
        }
        
        if let duration = try container.decodeIfPresent(Int.self, forKey: .duration) {
            self.duration = duration * 1000
        }
        
        if let image = try container.decodeIfPresent(String.self, forKey: .image) {
            self.image = image
        }

        if let file = try container.decodeIfPresent(String.self, forKey: .file) {
            self.file = file
        }

        if let lyrics = try container.decodeIfPresent(String.self, forKey: .lyrics) {
            self.lyrics = lyrics
            self.parseLyrics()
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Keys.self)
        try container.encode(singer, forKey: .singer)
        try container.encode(album, forKey: .album)
        try container.encode(title, forKey: .title)
        try container.encode(duration, forKey: .duration)
        try container.encode(image, forKey: .image)
        try container.encode(file, forKey: .file)
        try container.encode(lyrics, forKey: .lyrics)
    }

    enum Keys: String, CodingKey {
        case singer = "singer"
        case album = "album"
        case title = "title"
        case duration = "duration"
        case image = "image"
        case file = "file"
        case lyrics = "lyrics"
    }
    
    mutating func parseLyrics() {
        let values = self.lyrics.components(separatedBy: "\n")
        if values.count <= 0 {
            return
        }
        
        self.lyricsSyncs.append(LyricsCellModel(millisecond: -1, text: "간주", isFavorite: false))
        for value in values {
            let tokens = value.components(separatedBy: "]")
            if tokens.count < 2 {
                return
            }
            
            guard var timeString = tokens.first else {
                return
            }
            
            timeString = timeString.replacingOccurrences(of: "[", with: "")
            let millisecond = timeString.millisecond
            if millisecond - 4000 > 0 && self.lyricsSyncs.count == 1 {
                self.lyricsSyncs.append(LyricsCellModel(millisecond: millisecond - 3000, text: "3", isFavorite: false))
                self.lyricsSyncs.append(LyricsCellModel(millisecond: millisecond - 2000, text: "2", isFavorite: false))
                self.lyricsSyncs.append(LyricsCellModel(millisecond: millisecond - 1000, text: "1", isFavorite: false))
            }
            
            self.lyricsSyncs.append(LyricsCellModel(millisecond: millisecond, text: tokens.last!, isFavorite: false))
        }

        for _ in 0..<4 {
            self.lyricsSyncs.append(LyricsCellModel(millisecond: Int.max, text: "", isFavorite: false))
        }
    }
}

