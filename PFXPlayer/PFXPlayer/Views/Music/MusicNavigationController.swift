//
//  MusicNavigationController.swift
//  PFXPlayer
//
//  Created by succorer on 01/02/2020.
//  Copyright © 2020 PFXStudio. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class MusicNavigationController: UINavigationController {
    
    let topBottomSubject = PublishSubject<Bool>()
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.topBottomSubject
            .subscribe(onNext: { [weak self] isTop in
                guard let self = self else { return }
                // top is show
                UIView.animate(withDuration: 2) {
                    self.navigationBar.isHidden = !isTop
                    guard let childViewController = self.children.first as? MusicViewController else {
                        return
                    }

                    childViewController.topBottomSubject.onNext(isTop)
                }
            }, onError: { error in
                    print(error)
            })
            .disposed(by: self.disposeBag)
    }
}

extension MusicNavigationController : MusicViewProtocal {
    func prePareViewsForUpdate(musicModel: MusicModel) {
        guard let childViewController = self.children.first as? MusicViewController else {
            return
        }
        
        childViewController.prePareViewsForUpdate(musicModel: musicModel)
    }
}


