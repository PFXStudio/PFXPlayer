//
//  SingerViewController.swift
//  PFXPlayer
//
//  Created by succorer on 2020/02/03.
//  Copyright © 2020 PFXStudio. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class SingerViewController: UIViewController {
    
    @IBOutlet weak var singerLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    var viewModel = MusicViewModel()

    var disposeBag = DisposeBag()
    
    deinit {
        self.disposeBag = DisposeBag()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.closeButton.rx.tap
            .throttle(.seconds(1), latest: false, scheduler: MainScheduler.instance)
            .bind { [weak self] in
                guard let weakSelf = self else {
                    return
                }
                
                weakSelf.dismiss(animated: true, completion: nil)
        }
        .disposed(by: self.disposeBag)
        
        self.viewModel.coverViewModelData.asObservable().subscribeOn(MainScheduler.instance)
            .subscribe(onNext: { coverViewModel in
                self.singerLabel.text = coverViewModel.singer
            })
            .disposed(by: self.disposeBag)
    }
    
}
