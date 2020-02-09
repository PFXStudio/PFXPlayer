//
//  MusicPlayViewController.swift
//  PFXPlayer
//
//  Created by succorer on 02/02/2020.
//  Copyright © 2020 PFXStudio. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class MusicPlayViewController: UIViewController {
    
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var repeatButton: UIButton!
    @IBOutlet weak var backwardButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var forwardButton: UIButton!
    @IBOutlet weak var shuffleButton: UIButton!
    @IBOutlet weak var dragView: UIView!
    
    var disposeBag = DisposeBag()
    var viewModel = MusicViewModel()
    
    deinit {
        self.disposeBag = DisposeBag()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.bindViewModels()
        self.bindPlayButton()
        self.bindBackwardButton()
        self.bindForwardButton()
        self.bindMusicPlayer()
        
        let panGesture = dragView.rx
            .panGesture()
            .share(replay: 1)
        
        let tapGesture = dragView.rx
            .tapGesture()
            .share(replay: 1)
        
        panGesture
            .when(.changed)
            .subscribe(onNext: { (recognizer) in
                let point = recognizer.location(in: self.dragView)
                let x = Int(point.x)
                let size = self.dragView.frame.size
                let width = Int(size.width)
                if x < 0 {
                    return
                }
                
                if x > width {
                    return
                }
                
                let playModel = self.viewModel.playViewModelData.value
                let millisecond = playModel.endTimeText.millisecond
                let value = millisecond * x / Int(size.width)
                MusicPlayer.shared.move(millisecond: value)
            }, onError: { (error) in
                
            })
            .disposed(by: self.disposeBag)

        tapGesture
            .when(.recognized)
            .asLocation()
            .subscribe(onNext: { (point) in
                let x = Int(point.x)
                let size = self.dragView.frame.size
                let width = Int(size.width)
                if x < 0 {
                    return
                }
                
                if x > width {
                    return
                }
                
                let playModel = self.viewModel.playViewModelData.value
                let millisecond = playModel.endTimeText.millisecond * x / Int(size.width)
                MusicPlayer.shared.move(millisecond: millisecond)
            }, onError: { (error) in
                
            })
            .disposed(by: self.disposeBag)

    }
}

extension MusicPlayViewController {
    func bindViewModels() {
        self.viewModel.playViewModelData
            .asObservable()
            .subscribeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] playViewModel in
                guard let weakSelf = self else {
                    return
                }
                
                weakSelf.playButton.setImage(UIImage(systemName: playViewModel.imageName),  for: .normal)
                weakSelf.playButton.tag = playViewModel.buttonTag
                weakSelf.currentTimeLabel.text = playViewModel.currentTimeText
                weakSelf.endTimeLabel.text = playViewModel.endTimeText
                weakSelf.progressView.progress = playViewModel.progressValue
            })
            .disposed(by: self.disposeBag)
    }
    
    func bindPlayButton() {
        self.playButton.rx.tap
            .throttle(.seconds(1), latest: false, scheduler: MainScheduler.instance)
            .bind { [weak self] in
                
                guard let button = self?.playButton else {
                    return
                }
                
                if button.tag % 2 == 0 {
                    MusicPlayer.shared.play()
                    return
                }
                
                MusicPlayer.shared.pause()
        }
        .disposed(by: self.disposeBag)
    }
    
    func bindForwardButton() {
        self.forwardButton.rx.tap
            .subscribeOn(MainScheduler.instance)
            .throttle(.seconds(1), latest: false, scheduler: MainScheduler.instance)
            .bind { 
                MusicPlayer.shared.forward()
        }
        .disposed(by: self.disposeBag)
    }
    
    func bindBackwardButton() {
        self.backwardButton.rx.tap
            .subscribeOn(MainScheduler.instance)
            .throttle(.seconds(1), latest: false, scheduler: MainScheduler.instance)
            .subscribe(onNext: {
                MusicPlayer.shared.backward()
        }, onError: { error in
                print(error)
        })
        .disposed(by: self.disposeBag)
    }
    
    func bindMusicPlayer() {
        MusicPlayer.shared.updateSubject
            .subscribeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] (playModel) in
                guard let weakSelf = self else {
                    return
                }
                
                weakSelf.viewModel.update(playModel: playModel)
            }, onError: { error in
                    print(error)
            })
            .disposed(by: self.disposeBag)
    }
}



extension MusicPlayViewController : MusicViewProtocal {
    func prePareViewsForUpdate(musicModel: MusicModel) {
    }
}
