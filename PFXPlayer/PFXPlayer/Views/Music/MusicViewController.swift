//
//  MusicViewController.swift
//  PFXPlayer
//
//  Created by succorer on 01/02/2020.
//  Copyright © 2020 PFXStudio. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class MusicViewController: UIViewController {
    weak var musicCoverViewController: MusicCoverViewController?
    weak var musicPlayViewController: MusicPlayViewController?
    weak var musicMiniPlayViewController: MusicMiniPlayViewController?
    weak var musicBottomViewController: MusicBottomViewController?
    weak var musicLyricsViewController: MusicLyricsViewController?
    
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var musicMiniContainerView: UIView!
    @IBOutlet weak var bottomButtonItem: UIBarButtonItem!
    
    let topBottomSubject = PublishSubject<Bool>()
    var disposeBag = DisposeBag()
    
    deinit {
        self.disposeBag = DisposeBag()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.bindTopBottomSubject()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let destination = segue.destination as? MusicCoverViewController {
            self.musicCoverViewController = destination
            return
        }

        if let destination = segue.destination as? MusicPlayViewController {
            self.musicPlayViewController = destination
            return
        }

        if let destination = segue.destination as? MusicMiniPlayViewController {
            self.musicMiniPlayViewController = destination
            return
        }

        if let destination = segue.destination as? MusicBottomViewController {
            self.musicBottomViewController = destination
            return
        }
        
        if let destination = segue.destination as? MusicLyricsViewController {
            self.musicLyricsViewController = destination
            return
        }
    }
    
}


extension MusicViewController {
    func bindTopBottomSubject() {
        self.topBottomSubject
            .subscribe(onNext: { isTop in
                // top is show
                UIView.animate(withDuration: 1) {
                    if isTop == true {
                        self.topConstraint.constant = -44
                    }
                    else {
                        self.topConstraint.constant = 0
                    }
                    
                    self.view.layoutIfNeeded()
                }
            }, onError: { error in
                    print(error)
            })
            .disposed(by: self.disposeBag)
    }
}


extension MusicViewController : MusicViewProtocal {
    func prePareViewsForUpdate(musicModel: MusicModel) {
        self.musicCoverViewController?.prePareViewsForUpdate(musicModel: musicModel)
        self.musicPlayViewController?.prePareViewsForUpdate(musicModel: musicModel)
        self.musicMiniPlayViewController?.prePareViewsForUpdate(musicModel: musicModel)
        self.musicBottomViewController?.prePareViewsForUpdate(musicModel: musicModel)
        self.musicLyricsViewController?.prePareViewsForUpdate(musicModel: musicModel)
    }
}

