//
//  CommonValues.swift
//  PFXPlayer
//
//  Created by succorer on 01/02/2020.
//  Copyright © 2020 PFXStudio. All rights reserved.
//

import Foundation
import UIKit

let kFavoriteKey = "kFavoriteKey"

class CommonValues {
    static let playBarHeight: CGFloat = 44
    static let playPanelAnimationDuration: Double = 0.2
    static let bounceDownConstant: CGFloat = 15
    static let bounceUpConstant: CGFloat = 10
}

public enum PlayStatus: Int {
    case stop = 0
    case play
    case pause
    case backward
    case forward
}

public enum LyricsScale: Int {
    case x1 = 14
    case x2 = 18
    case x4 = 22
}

