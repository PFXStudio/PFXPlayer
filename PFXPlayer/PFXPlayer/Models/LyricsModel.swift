//
//  LyricsModel.swift
//  PFXPlayer
//
//  Created by succorer on 02/02/2020.
//  Copyright © 2020 PFXStudio. All rights reserved.
//

import Foundation
import RxDataSources

public struct LyricsCellModel {
    public var millisecond: Int = 0
    public var text = ""
    public var scale = LyricsScale.x1
    public var isFavorite = false
}

public struct LyricsModel {
    public var header: String
    public var items: [Item]
}

extension LyricsModel
    : SectionModelType {
    public typealias Item = LyricsCellModel

    public init(original: LyricsModel, items: [Item]) {
        self.header = original.header
        self.items = items
    }
}
