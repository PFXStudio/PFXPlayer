//
//  MusicPanelViewController.swift
//  PFXPlayer
//
//  Created by succorer on 01/02/2020.
//  Copyright © 2020 PFXStudio. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxGesture
import Hero
import NVActivityIndicatorView

class MusicPanelViewController: UIViewController, NVActivityIndicatorViewable {
    @IBOutlet var panGestureRecognizer: UIPanGestureRecognizer!
    @IBOutlet weak var topLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomLayoutConstraint: NSLayoutConstraint!
    
    weak var musicNavigationController: MusicNavigationController?

    var disposeBag = DisposeBag()
    var translations = [CGFloat]()
    var maxCheckCount = 5
    var maxDown:CGFloat = 0
    let bottomSubject = PublishSubject<Bool>()
    var networkClient = NetworkClient()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let panGesture = view.rx
            .panGesture()
            .share(replay: 1)
        
        panGesture
            .when(.changed)
            .asTranslation()
            .subscribe(onNext: { [weak self] translation, _ in
                guard let self = self else { return }
                if self.translations.count >= self.maxCheckCount {
                    self.translations.removeFirst()
                }
                
                self.translations.append(translation.y)
                
                if self.translations.count < 2 {
                    return
                }
                
                let oldY = self.translations[self.translations.count - 2]
                let newY = self.translations[self.translations.count - 1]
                self.move(oldY: oldY, newY: translation.y)
            }, onError: { error in
                    print(error)
            })
            .disposed(by: self.disposeBag)
        
        panGesture
            .when(.ended)
            .asTranslation()
            .subscribe(onNext: { [weak self] translation, _ in
                guard let self = self else { return }
                var resultFunction: () -> () = self.moveToNear
                defer {
                    self.translations.removeAll()
                    resultFunction()
                }
                
                guard let first = self.translations.first, let last = self.translations.last, self.translations.count >= self.maxCheckCount else {
                    return
                }
                
                if first < 0 && last > 0 ||
                   last < 0 && first > 0 {
                    return
                }

                let validY: CGFloat = 10
                if first < last {
                    let distance = last - first
                    if distance > validY {
                        resultFunction = self.moveToBottom
                        return
                    }
                    
                    return
                }
                
                if last < first {
                    let distance = abs(first) - abs(last)
                    if abs(distance) > validY {
                        resultFunction = self.moveToTop
                        return
                    }
                    
                    return
                }
            }, onError: { error in
                    print(error)
            })
            .disposed(by: self.disposeBag)
    }
    
    deinit {
        self.disposeBag = DisposeBag()
    }
    
    private let presentingIndicatorTypes = {
        return NVActivityIndicatorType.allCases.filter { $0 != .blank }
    }()


    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if MusicPlayer.shared.musicModel.value != nil {
            return
        }
        
        let size = CGSize(width: 30, height: 30)
        let selectedIndicatorIndex = 15
        let indicatorType = presentingIndicatorTypes[selectedIndicatorIndex]
        startAnimating(size, message: "Loading...", type: indicatorType, fadeInAnimation: nil)
        
        var musicModel: MusicModel?
        self.networkClient.requestMusicModel()
            .map{model -> MusicModel in
                musicModel = model
                return model
            }
            .map{URL(string: $0.file)}
            .flatMap{self.networkClient.requestMusicDownload(url: $0!)}
            .do(onDispose: {self.stopAnimating(nil)})
            .subscribe(onNext: { [weak self] fileData in
                guard let self = self, let model = musicModel else { return }
                var musicModel = model
                musicModel.data = fileData
                MusicPlayer.shared.update(musicModel: musicModel)
                self.musicNavigationController?.prePareViewsForUpdate(musicModel: musicModel)
            }, onError: { error in
                self.stopAnimating(nil)
                print(error)
            }, onCompleted: {
                self.stopAnimating(nil)
                self.moveToBottom()
            })
            .disposed(by: self.disposeBag)
        
        guard let musicNavigationController = self.musicNavigationController else {
            return
        }
        
        guard let childViewController = musicNavigationController.children.first as? MusicViewController else {
            return
        }
        
        childViewController.bottomButtonItem.rx.tap
            .throttle(.seconds(1), latest: false, scheduler: MainScheduler.instance)
            .bind { [weak self] in
                guard let weakSelf = self else {
                    return
                }
                
                weakSelf.moveToBottom()
            }
            .disposed(by: self.disposeBag)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.maxDown = self.view.frame.size.height - CommonValues.playBarHeight - CommonValues.playBarHeight - CommonValues.playBarHeight
    }
    
    func move(oldY: CGFloat, newY: CGFloat) {
        if oldY < newY {
            // down
            let distance = self.topLayoutConstraint.constant + (newY - oldY)
            self.topLayoutConstraint.constant = min(self.maxDown, distance)
            self.bottomLayoutConstraint.constant = min(self.maxDown, distance)
        }
        
        if oldY > newY {
            // up
            let firstY = max(abs(oldY), abs(newY))
            let lastY = min(abs(oldY), abs(newY))
            let distance = (self.topLayoutConstraint.constant - (firstY - lastY))
            self.topLayoutConstraint.constant = max(0, distance)
            self.bottomLayoutConstraint.constant = max(0, distance)
        }
    }
    
    func moveToTop() {
        print("\(#function)")
        self.bottomSubject.onNext(false)
        UIView.animate(withDuration: CommonValues.playPanelAnimationDuration, animations: {
            self.topLayoutConstraint.constant = CommonValues.bounceDownConstant * -1
            self.bottomLayoutConstraint.constant = CommonValues.bounceDownConstant * -1
            self.view.layoutIfNeeded()
        }) { (result) in
            UIView.animate(withDuration: 0.1, animations: {
                self.topLayoutConstraint.constant = CommonValues.bounceUpConstant
                self.bottomLayoutConstraint.constant = CommonValues.bounceUpConstant
                self.navigationController?.navigationBar.isHidden = false
                self.view.layoutIfNeeded()
                self.musicNavigationController?.topBottomSubject.onNext(true)
            }) { (result) in
                UIView.animate(withDuration: 0.1, animations: {
                    self.topLayoutConstraint.constant = 0
                    self.bottomLayoutConstraint.constant = 0
                    self.view.layoutIfNeeded()
                }) { (result) in
                    
                }
            }
        }
    }
    
    func moveToBottom() {
        print("\(#function)")
        self.bottomSubject.onNext(true)
        UIView.animate(withDuration: CommonValues.playPanelAnimationDuration, animations: {
            self.topLayoutConstraint.constant = self.maxDown + CommonValues.bounceDownConstant
            self.bottomLayoutConstraint.constant = self.maxDown + CommonValues.bounceDownConstant
            self.view.layoutIfNeeded()
        }) { (result) in
            UIView.animate(withDuration: 0.1, animations: {
                self.topLayoutConstraint.constant = self.maxDown - CommonValues.bounceUpConstant
                self.bottomLayoutConstraint.constant = self.maxDown - CommonValues.bounceUpConstant
                self.navigationController?.navigationBar.isHidden = true
                self.view.layoutIfNeeded()
                self.musicNavigationController?.topBottomSubject.onNext(false)
            }) { (result) in
                UIView.animate(withDuration: 0.1, animations: {
                    self.topLayoutConstraint.constant = self.maxDown
                    self.bottomLayoutConstraint.constant = self.maxDown
                    self.view.layoutIfNeeded()
                }) { (result) in
                    
                }
            }
        }
    }
    
    func moveToNear() {
        print("\(#function)")
        let center = self.maxDown / 2
        if self.topLayoutConstraint.constant <= center {
            self.moveToTop()
            return
        }
        
        self.moveToBottom()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        guard let destination = segue.destination as? MusicNavigationController else {
            return
        }
        
        self.musicNavigationController = destination
    }
}
