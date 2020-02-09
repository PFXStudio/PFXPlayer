//
//  LyricsViewController.swift
//  PFXPlayer
//
//  Created by succorer on 01/02/2020.
//  Copyright © 2020 PFXStudio. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class LyricsViewController: UIViewController {
    
    @IBOutlet weak var scaleButton: UIButton!
    @IBOutlet weak var currentButton: UIButton!
    @IBOutlet weak var closeButtonItem: UIBarButtonItem!
    
    var disposeBag = DisposeBag()
    
    weak var listLyricsViewController: ListLyricsViewController?
    weak var musicMiniPlayViewController: MusicMiniPlayViewController?
    
    deinit {
        self.disposeBag = DisposeBag()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.bindCloseButton()
        self.bindScaleButton()
        self.bindCurrentButton()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if let destination = segue.destination as? ListLyricsViewController {
            self.listLyricsViewController = destination
            destination.viewModel.isMiniSize.accept(false)
        }

        if let destination = segue.destination as? MusicMiniPlayViewController {
            self.musicMiniPlayViewController = destination
        }
        
        guard let musicModel = MusicPlayer.shared.musicModel.value else {
            return
        }
        
        self.prePareViewsForUpdate(musicModel: musicModel)
    }
}

extension LyricsViewController {
    func bindCloseButton() {
        self.closeButtonItem.rx.tap
            .throttle(.seconds(1), latest: false, scheduler: MainScheduler.instance)
            .bind { [weak self] in
                guard let weakSelf = self else {
                    return
                }
                
                weakSelf.dismiss(animated: true, completion: nil)
        }
        .disposed(by: self.disposeBag)
    }
    
    func bindScaleButton() {
        self.scaleButton.rx.tap
            .throttle(.seconds(1), latest: false, scheduler: MainScheduler.instance)
            .bind { [weak self] in
                guard let weakSelf = self else {
                    return
                }
                
                guard let controller = weakSelf.listLyricsViewController else {
                    return
                }
                
                controller.viewModel.toggledScale()
        }
        .disposed(by: self.disposeBag)
        
        guard let controller = self.listLyricsViewController else {
            return
        }
        
        controller.viewModel.scaleValue
            .asDriver()
            .drive(onNext: { [weak self] scale in
                guard let weakSelf = self else {
                    return
                }

                if scale == .x1 {
                    weakSelf.scaleButton.setImage(UIImage(systemName: "1.circle"), for: .normal)
                    return
                }
            
                if scale == .x2 {
                    weakSelf.scaleButton.setImage(UIImage(systemName: "2.circle"), for: .normal)
                    return
                }
            
                if scale == .x4 {
                    weakSelf.scaleButton.setImage(UIImage(systemName: "4.circle"), for: .normal)
                    return
                }
            })
            .disposed(by: self.disposeBag)
    }
    
    func bindCurrentButton() {
        self.currentButton.rx.tap
            .throttle(.seconds(1), latest: false, scheduler: MainScheduler.instance)
            .bind { [weak self] in
                guard let weakSelf = self else {
                    return
                }
                
                guard let controller = weakSelf.listLyricsViewController else {
                    return
                }
    
                controller.viewModel.toggledAutoScroll(isAuto: true)
        }
        .disposed(by: self.disposeBag)
        
        guard let controller = self.listLyricsViewController else {
            return
        }
        
        controller.viewModel.autoScroll
            .asObservable()
            .subscribeOn(MainScheduler.instance)
            .subscribe(onNext: { isAuto in
                self.currentButton.isEnabled = !isAuto
            }, onError: { error in
                    print(error)
            })
            .disposed(by: self.disposeBag)
    }
}


extension LyricsViewController : MusicViewProtocal {
    func prePareViewsForUpdate(musicModel: MusicModel) {
        self.listLyricsViewController?.prePareViewsForUpdate(musicModel: musicModel)
        self.musicMiniPlayViewController?.prePareViewsForUpdate(musicModel: musicModel)
    }
}
