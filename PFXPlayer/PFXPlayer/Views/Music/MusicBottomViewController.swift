//
//  MusicBottomViewController.swift
//  PFXPlayer
//
//  Created by succorer on 02/02/2020.
//  Copyright © 2020 PFXStudio. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class MusicBottomViewController: UIViewController {
    
    @IBOutlet weak var similarButton: UIButton!
    @IBOutlet weak var wifiButton: UIButton!
    @IBOutlet weak var listButton: UIButton!
}

extension MusicBottomViewController : MusicViewProtocal {
    func prePareViewsForUpdate(musicModel: MusicModel) {
        
    }
}
