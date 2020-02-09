//
//  PlayCoverViewController.swift
//  PFXPlayer
//
//  Created by succorer on 02/02/2020.
//  Copyright © 2020 PFXStudio. All rights reserved.
//

import Foundation
import UIKit
import Nuke
import RxSwift

class MusicCoverViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var singerButton: UIButton!
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var likeButton: UIButton!

    var viewModel = MusicViewModel()
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.bindControllers()
        self.bindCoverImageView()
        self.bindSingerButton()
        self.bindLikeButton()
    }
}

extension MusicCoverViewController {
    func bindControllers() {
        self.viewModel.coverViewModelData.asObservable()
            .subscribeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] viewModel in
                guard let weakSelf = self else {
                    return
                }
                
                weakSelf.titleLabel.text = viewModel.title
                weakSelf.singerButton.setTitle(viewModel.singer + "  ", for: .normal)
                if let url = URL(string: viewModel.imagePath) {
                    Nuke.loadImage(with: url, into: weakSelf.coverImageView)
                }
            })
            .disposed(by: self.disposeBag)
    }
    
    func bindCoverImageView() {
        let tapGesture = self.coverImageView.rx
            .tapGesture()
            .share(replay: 1)
        
        tapGesture
            .when(.recognized)
            .asLocation()
            .subscribe(onNext: { [weak self] (point) in
                guard let weakSelf = self else {
                    return
                }
                
                guard let controller = UIStoryboard.init(name: "Viewer", bundle: nil).instantiateViewController(identifier: String(describing: ImageViwerController.self)) as? ImageViwerController else {
                    return
                }
                
                controller.path = weakSelf.viewModel.coverViewModelData.value.imagePath
                controller.hero.isEnabled = true
                controller.hero.modalAnimationType = .selectBy(presenting: .zoom, dismissing: .zoomOut)
                weakSelf.present(controller, animated: true, completion: nil)
            }, onError: { (error) in
                
            })
            .disposed(by: self.disposeBag)
    }
    
    func bindSingerButton() {
        self.singerButton.rx.tap
            .throttle(.seconds(1), latest: false, scheduler: MainScheduler.instance)
            .bind { [weak self] in
                guard let weakSelf = self else {
                    return
                }
                
                guard let controller = UIStoryboard.init(name: "Singer", bundle: nil).instantiateViewController(identifier: String(describing: SingerViewController.self)) as? SingerViewController else {
                    return
                }
                
                controller.hero.isEnabled = true
                controller.hero.modalAnimationType = .selectBy(presenting: .zoom, dismissing: .zoomOut)
                weakSelf.present(controller, animated: true, completion: {
                    controller.viewModel.coverViewModelData.accept((self?.viewModel.coverViewModelData.value)!)
                })
        }
        .disposed(by: self.disposeBag)
    }
    
    func bindLikeButton() {
        self.likeButton.rx.tap
            .throttle(.seconds(1), latest: false, scheduler: MainScheduler.instance)
            .bind { [weak self] in
                guard let weakSelf = self else {
                    return
                }
        }
        .disposed(by: self.disposeBag)

    }
}


extension MusicCoverViewController : MusicViewProtocal {
    func prePareViewsForUpdate(musicModel: MusicModel) {
        self.viewModel.update(musicModel: musicModel)
    }
}
