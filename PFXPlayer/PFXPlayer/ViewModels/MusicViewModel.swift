//
//  MusicViewModel.swift
//  PFXPlayer
//
//  Created by succorer on 2020/02/03.
//  Copyright © 2020 PFXStudio. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay

public class MusicViewModel {
    var playViewModelData = BehaviorRelay<PlayViewModel>(value: PlayViewModel(imageName: "play.fill", buttonTag: 0, currentTimeText: "00:00", endTimeText: "00:00", progressValue: 0))
    var coverViewModelData = BehaviorRelay<CoverViewModel>(value: CoverViewModel(title: "", singer: ""))
    
    func update(musicModel: MusicModel) {
        self.coverViewModelData.accept(CoverViewModel(title: musicModel.title, singer: musicModel.singer, imagePath: musicModel.image))
    }
    
    func update(playModel: PlayModel) {
        var tag = 0
        var imageName = "play.fill"
        if playModel.status == .play {
            imageName = "pause.fill"
            tag = 1
        }

        let currentTimeText = playModel.millisecond.millisecondToString
        let endTimeText = playModel.duration.millisecondToString
        let value = 1 / (Float(playModel.duration) / Float(playModel.millisecond))
        
        self.playViewModelData.accept(PlayViewModel(imageName: imageName, buttonTag: tag, currentTimeText: currentTimeText, endTimeText: endTimeText, progressValue: value))
    }
}
