//
//  SplashViewController.swift
//  PFXPlayer
//
//  Created by succorer on 31/01/2020.
//  Copyright © 2020 PFXStudio. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class SplashViewController: UIViewController {
    
    let delaySubject = PublishSubject<Bool>()
    let disposeBag = DisposeBag()
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        Observable.just("")
            .delay(RxTimeInterval.seconds(1), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                let mainViewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: String(describing: MainViewController.self))
                mainViewController.modalPresentationStyle = .fullScreen
                mainViewController.modalTransitionStyle = .crossDissolve
                self.present(mainViewController, animated: true, completion: nil)
            }, onError: { error in
                    print(error)
            })
            .disposed(by: self.disposeBag)
    }
}
