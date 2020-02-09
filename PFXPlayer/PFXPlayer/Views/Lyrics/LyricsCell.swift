//
//  LyricsCell.swift
//  PFXPlayer
//
//  Created by succorer on 02/02/2020.
//  Copyright © 2020 PFXStudio. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class LyricsCell: UITableViewCell {
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    
    var disposeBag = DisposeBag()
    var selectedFavoriteButton: ((LyricsCellModel)-> Void)?
    
    deinit {
        self.disposeBag = DisposeBag()
    }
    
    func initialize() {
        self.label.text = ""
        self.label.font = UIFont.systemFont(ofSize: CGFloat(LyricsScale.x1.rawValue), weight: .medium)
        self.label.textColor = UIColor.darkGray
        self.widthConstraint.constant = 0
        self.favoriteButton.tintColor = UIColor.darkGray
        self.selectedBackgroundView?.tintColor = UIColor.clear
    }
    
    func updateControllers(item: LyricsCellModel, isMiniSize: Bool, selectedFavoriteButton:@escaping (LyricsCellModel) -> Void) {
        self.initialize()
        self.selectedFavoriteButton = selectedFavoriteButton
        self.label.text = item.text
        if item.scale == .x2 {
            self.label.font = UIFont.systemFont(ofSize: CGFloat(LyricsScale.x2.rawValue), weight: .medium)
        }
        
        if item.scale == .x4 {
            self.label.font = UIFont.systemFont(ofSize: CGFloat(LyricsScale.x4.rawValue), weight: .medium)
        }
        
        if item.isFavorite == true && isMiniSize == false {
            self.widthConstraint.constant = 21
            self.favoriteButton.tintColor = UIColor.yellow
        }
    }
    
    func focus() {
        self.label.textColor = UIColor.white
    }

    func nonFocus() {
        self.label.textColor = UIColor.darkGray
    }
}

extension LyricsCell {
    func bindFavoriteButton(item: LyricsCellModel) {
        if item.isFavorite == true {
            self.favoriteButton.tintColor = UIColor.yellow
        }
        else {
            self.favoriteButton.tintColor = UIColor.darkGray
        }
        
        self.favoriteButton.rx.tap
            .throttle(.seconds(1), latest: false, scheduler: MainScheduler.instance)
            .bind { [weak self] in
                guard let weakSelf = self else {
                    return
                }
                
                guard let completion = weakSelf.selectedFavoriteButton else {
                    return
                }
                
                completion(item)
        }
        .disposed(by: self.disposeBag)
    }
}
