//
//  MusicLyricsViewController.swift
//  PFXPlayer
//
//  Created by succorer on 02/02/2020.
//  Copyright © 2020 PFXStudio. All rights reserved.
//

import Foundation
import RxSwift

class MusicLyricsViewController: UIViewController {
    
    weak var miniKyricsViewController: ListLyricsViewController?
    var disposeBag = DisposeBag()
    
    deinit {
        self.disposeBag = DisposeBag()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.bindView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard let controller = self.miniKyricsViewController else {
            return
        }
        
        controller.viewModel.toggledAutoScroll(isAuto: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard let destination = segue.destination as? ListLyricsViewController else {
            return
        }
        
        self.miniKyricsViewController = destination
        destination.viewModel.isMiniSize.accept(true)
        destination.viewModel.toggledAutoScroll(isAuto: true)
    }
}

extension MusicLyricsViewController {
    func bindView() {
        let tapGesture = UITapGestureRecognizer()
        self.view.addGestureRecognizer(tapGesture)
        tapGesture.rx.event.bind(onNext: { [weak self] recognizer in
            guard let weakSelf = self else {
                return
            }
            
            let lyricsViewController = UIStoryboard(name: "Lyrics", bundle: nil).instantiateViewController(identifier: String(describing: "LyricsNavigationController"))
            lyricsViewController.modalPresentationStyle = .fullScreen
            lyricsViewController.modalTransitionStyle = .crossDissolve
            weakSelf.present(lyricsViewController, animated: true, completion: nil)
        }).disposed(by: self.disposeBag)
    }
}

extension MusicLyricsViewController : MusicViewProtocal {
    func prePareViewsForUpdate(musicModel: MusicModel) {
        self.miniKyricsViewController?.prePareViewsForUpdate(musicModel: musicModel)
    }
}
