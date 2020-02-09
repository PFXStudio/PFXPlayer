//
//  MusicMiniPlayViewController.swift
//  PFXPlayer
//
//  Created by succorer on 02/02/2020.
//  Copyright © 2020 PFXStudio. All rights reserved.
//

import Foundation
import UIKit
import RxAnimated
import MarqueeLabel
import RxSwift

class MusicMiniPlayViewController: UIViewController {
    @IBOutlet weak var titleLabel: MarqueeLabel!
    @IBOutlet weak var singerLabel: UILabel!
    @IBOutlet weak var backwardButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var forwardButton: UIButton!
    @IBOutlet weak var listButton: UIButton!
    @IBOutlet weak var progressView: UIProgressView!
    
    var viewModel = MusicViewModel()
    var disposeBag = DisposeBag()
    
    deinit {
        self.disposeBag = DisposeBag()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.bindViewModels()
        self.bindPlayButton()
        self.bindForwardButton()
        self.bindBackwardButton()
        self.bindMusicPlayer()
    }
}

extension MusicMiniPlayViewController : MusicViewProtocal {
    func prePareViewsForUpdate(musicModel: MusicModel) {
        self.viewModel.update(musicModel: musicModel)
    }
}

extension MusicMiniPlayViewController {
    func bindViewModels() {
        self.viewModel.playViewModelData
            .asObservable()
            .subscribeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] playModel in
                guard let weakSelf = self else {
                    return
                }
                
                weakSelf.playButton.setImage(UIImage(systemName: playModel.imageName), for: .normal)
                weakSelf.playButton.tag = playModel.buttonTag
                weakSelf.progressView.progress = playModel.progressValue
            })
            .disposed(by: self.disposeBag)
        
        self.viewModel.coverViewModelData
            .asObservable()
            .subscribeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] coverViewModel in
                guard let weakSelf = self else {
                    return
                }
                
                weakSelf.titleLabel.text = coverViewModel.title
                if weakSelf.titleLabel.isTruncated == true {
                    weakSelf.titleLabel.text = coverViewModel.title + "\t\t"
                    weakSelf.titleLabel.type = .continuous
                    weakSelf.titleLabel.animationCurve = .easeInOut
                    weakSelf.titleLabel.fadeLength = 15
                }
                
                weakSelf.singerLabel.text = coverViewModel.singer
            })
            .disposed(by: self.disposeBag)
    }
    
    func bindPlayButton() {
        self.playButton.rx.tap
            .throttle(.seconds(1), latest: false, scheduler: MainScheduler.instance)
            .bind { [weak self] in
                guard let weakSelf = self else {
                    return
                }
                
                guard let button = weakSelf.playButton else {
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
    

}

