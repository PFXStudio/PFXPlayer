//
//  MusicPlayerProtocol.swift
//  PFXPlayer
//
//  Created by succorer on 02/02/2020.
//  Copyright © 2020 PFXStudio. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay

protocol MusicPlayerProtocol {
    var musicModel: BehaviorRelay<MusicModel?> { get }
    var updateSubject: PublishSubject<PlayModel> { get }

    func backward()
    func forward()
    func pause()
    func play()
    func stop()
    func move(millisecond: Int)
    func millisecondToIndex(millisecond: Int) -> Int
    func update(musicModel: MusicModel)
}
