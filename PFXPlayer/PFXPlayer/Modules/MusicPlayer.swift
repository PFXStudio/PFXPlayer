//
//  MusicPlayer.swift
//  PFXPlayer
//
//  Created by succorer on 02/02/2020.
//  Copyright © 2020 PFXStudio. All rights reserved.
//

import Foundation
import RxSwift
import AVKit
import RxRelay

class MusicPlayer: MusicPlayerProtocol {
    public static let shared: MusicPlayerProtocol = MusicPlayer()
    var musicModel = BehaviorRelay<MusicModel?>(value: nil)
    var playModel = PlayModel(millisecond: 0, duration: 0, status: .stop)
    var disposeBag = DisposeBag()
    var audioPlayer: AVAudioPlayer?
    private let timer = Observable<Int>.timer(RxTimeInterval.milliseconds(100), period: RxTimeInterval.milliseconds(100), scheduler: MainScheduler.instance)
    var updateSubject = PublishSubject<PlayModel>()
    
    deinit {
        self.disposeBag = DisposeBag()
    }
    
    func initialize() {
        if let audioPlayer = self.audioPlayer {
            audioPlayer.stop()
            audioPlayer.currentTime = TimeInterval(0)
        }

        self.disposeBag = DisposeBag()
    }
    
    func update(musicModel: MusicModel) {
        self.musicModel.accept(musicModel)
        if self.audioPlayer == nil {
            do {
                try self.audioPlayer = AVAudioPlayer(data: musicModel.data!)
            } catch {
            }
            
            self.audioPlayer!.prepareToPlay()
        }
    }
    
    func hasFavorite() -> Bool {
        if let index = UserDefaults.standard.integer(forKey: kFavoriteKey) as Int? {
            return index != 0 ? true : false
        }
        
        return false
    }
    
    func millisecondToIndex(millisecond: Int) -> Int {
        guard let musicModel = self.musicModel.value else {
            return 0
        }
        
        for i in 1..<musicModel.lyricsSyncs.count {
            let cellModel = musicModel.lyricsSyncs[i]
            if millisecond > cellModel.millisecond {
                continue
            }
            
            return i - 1
        }
        
        return 0
    }

    func indexToMillisecond(index: Int) -> Int {
        guard let musicModel = self.musicModel.value else {
            return 0
        }
        
        if index < 0 || index >= musicModel.lyricsSyncs.count {
            return 0
        }

        return musicModel.lyricsSyncs[index].millisecond
    }


    func backward() {
        print("\(#function)")
        guard let musicModel = self.musicModel.value else {
            return
        }
        
        self.playModel = PlayModel(millisecond: 0, duration: musicModel.duration, status: .backward)
        self.updateSubject.onNext(self.playModel)
        self.initialize()
        self.play()
    }
    
    func forward() {
        print("\(#function)")
        guard let musicModel = self.musicModel.value else {
            return
        }
        
        self.playModel = PlayModel(millisecond: 0, duration: musicModel.duration, status: .forward)
        self.updateSubject.onNext(self.playModel)
        self.initialize()
        self.play()
    }
    
    func pause() {
        print("\(#function)")
        guard let musicModel = self.musicModel.value else {
            return
        }

        guard let audioPlayer = self.audioPlayer else {
            return
        }
        
        audioPlayer.pause()
        let millisecond = Int(audioPlayer.currentTime * 1000)
        self.playModel = PlayModel(millisecond: millisecond, duration: musicModel.duration, status: .pause)
        self.updateSubject.onNext(self.playModel)
        self.disposeBag = DisposeBag()
    }

    func stop() {
        print("\(#function)")
        guard let musicModel = self.musicModel.value else {
            return
        }
        
        self.playModel = PlayModel(millisecond: 0, duration: musicModel.duration, status: .stop)
        self.updateSubject.onNext(self.playModel)
        self.initialize()
    }

    func move(millisecond: Int) {
        guard let musicModel = self.musicModel.value else {
            return
        }
        
        guard let audioPlayer = self.audioPlayer else {
            return
        }
        
        audioPlayer.currentTime = TimeInterval(millisecond / 1000)
        audioPlayer.prepareToPlay()

        if self.playModel.status == .play {
            audioPlayer.play()
            return
        }
        
        self.playModel = PlayModel(millisecond: millisecond, duration: musicModel.duration, status: .stop)
        self.updateSubject.onNext(self.playModel)
    }

    func play() {
        print("\(#function)")
        guard let musicModel = self.musicModel.value else {
            return
        }
        
        guard let audioPlayer = self.audioPlayer else {
            return
        }
        
        audioPlayer.play()
        self.disposeBag = DisposeBag()
        self.timer
            .subscribe(onNext: { [unowned self] tick in
                let millisecond = Int(audioPlayer.currentTime * 1000)
                if millisecond >= musicModel.duration {
                    self.stop()
                    return
                }
          
                if audioPlayer.isPlaying == false {
                    print("stoped re play")
                    audioPlayer.play()
                }

                self.playModel = PlayModel(millisecond: millisecond, duration:musicModel.duration, status: .play)
                self.updateSubject.onNext(self.playModel)
            }, onError: { error in
                    print(error)
            })
            .disposed(by: self.disposeBag)
    }
}
