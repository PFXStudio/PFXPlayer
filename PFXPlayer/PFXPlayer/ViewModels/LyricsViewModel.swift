//
//  LyricsViewModel.swift
//  PFXPlayer
//
//  Created by succorer on 02/02/2020.
//  Copyright © 2020 PFXStudio. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay

public class LyricsViewModel {
 
    typealias ReactiveSection = BehaviorRelay<[LyricsModel]>
    var data = ReactiveSection(value: [])
    var scaleValue = BehaviorRelay<LyricsScale>(value: LyricsScale.x1)
    var favorite = BehaviorRelay<Int>(value: -1)
    var autoScroll = BehaviorRelay<Bool>(value: true)
    var isMiniSize = BehaviorRelay<Bool>(value: true)

    init() {
        self.data.accept([LyricsModel(header: "", items: [LyricsCellModel]())])
        if let index = UserDefaults.standard.integer(forKey: kFavoriteKey) as Int? {
            if index != 0 {
                self.favorite.accept(index)
            }
        }
    }
    
    func update(items: [LyricsCellModel]) {
        self.data.accept([LyricsModel(header: "", items: items)])
    }
    
    func toggledScale() {
        if self.scaleValue.value == LyricsScale.x1 {
            self.scaleValue.accept(LyricsScale.x2)
            return
        }
        else if self.scaleValue.value == LyricsScale.x2 {
            self.scaleValue.accept(LyricsScale.x4)
            return
        }
        
        self.scaleValue.accept(LyricsScale.x1)
    }
    
    func toggledAutoScroll(isAuto: Bool) {
        self.autoScroll.accept(isAuto)
    }
    
    func toggledFavorite(index: Int, isSelected: Bool) {
        if index == 0 {
            return
        }
        
        DispatchQueue.main.async {
            UserDefaults.standard.removeObject(forKey: kFavoriteKey)
            defer {
                UserDefaults.standard.synchronize()
            }
            
            if isSelected == false {
                self.favorite.accept(-1)
                return
            }
            
            let lyricsModel = self.data.value.first?.items[index]

            UserDefaults.standard.set(index, forKey: kFavoriteKey)
            self.favorite.accept(index)
            MusicPlayer.shared.move(millisecond: lyricsModel!.millisecond)
        }
    }
}
