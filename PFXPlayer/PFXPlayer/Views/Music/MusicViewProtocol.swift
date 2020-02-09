//
//  MusicViewProtocol.swift
//  PFXPlayer
//
//  Created by succorer on 02/02/2020.
//  Copyright © 2020 PFXStudio. All rights reserved.
//

import Foundation
import RxSwift

protocol MusicViewProtocal: class {
    func prePareViewsForUpdate(musicModel: MusicModel)
}
