//
//  ImageViewer.swift
//  PFXPlayer
//
//  Created by succorer on 04/02/2020.
//  Copyright © 2020 PFXStudio. All rights reserved.
//

import Foundation
import UIKit
import WebKit
import RxSwift
import Nuke

class ImageViewerController: UIViewController {
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    
    var path = ""
    var disposeBag = DisposeBag()
    
    deinit {
        self.disposeBag = DisposeBag()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.bindCloseButton()
        self.bindImageview()
    }
    
    func bindImageview() {
        if self.path.count <= 0 {
            return
        }
        
        if let url = URL(string: self.path) {
            Nuke.loadImage(with: url, into: self.imageView)
        }
    }
    
    func bindCloseButton() {
        self.closeButton.rx.tap
            .throttle(.seconds(1), latest: false, scheduler: MainScheduler.instance)
            .bind { [weak self] in
                guard let weakSelf = self else {
                    return
                }
                
                weakSelf.dismiss(animated: true, completion: nil)
        }
        .disposed(by: self.disposeBag)
    }
    
}
