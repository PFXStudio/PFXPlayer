//
//  MainViewController.swift
//  PFXPlayer
//
//  Created by succorer on 31/01/2020.
//  Copyright © 2020 PFXStudio. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class MainViewController: UIViewController {
    @IBOutlet weak var bottomLayoutConstraint: NSLayoutConstraint!

    @IBOutlet weak var descriptionLabel: UILabel!
    var disposeBag = DisposeBag()
    weak var MusicPanelViewController: MusicPanelViewController?
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var dragButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.descriptionLabel.text = "지원버전\niOS 13 - SF Symbol icon을 사용함 😭\n\n하단 미니 플레이어를 위로 올리면 전체화면으로 변경 됩니다.\n\n\n\n지금, 당신의 음악 FLO 🙌"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if isBeingPresented || isMovingToParent {
            self.recursiveAnimation()
        }
    }
    
    func recursiveAnimation() {
        UIView.animate(withDuration: 0.7, animations: {
            self.bottomConstraint.constant = self.view.frame.size.height / 4
            self.dragButton.alpha = 1
            self.view.layoutIfNeeded()
        }) { (result) in
            UIView.animate(withDuration: 0.3, animations: {
                self.bottomConstraint.constant = 60
                self.dragButton.alpha = 0
                self.view.layoutIfNeeded()
            }) { (result) in
                self.recursiveAnimation()
            }
        }
    }
    
    deinit {
        self.disposeBag = DisposeBag()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard let destination = segue.destination as? MusicPanelViewController else {
            return
        }
        
        self.MusicPanelViewController = destination
        self.MusicPanelViewController?.bottomSubject.subscribe(onNext: { (isBottom) in
            UIView.animate(withDuration: CommonValues.playPanelAnimationDuration) {
                if isBottom == true {
                    self.bottomLayoutConstraint.constant = 0
                    self.view.layoutIfNeeded()
                    return
                }
                
                self.bottomLayoutConstraint.constant = CommonValues.playBarHeight
                self.view.layoutIfNeeded()
            }
        }, onError: { error in
                print(error)
        })
        .disposed(by: self.disposeBag)
    }
}
