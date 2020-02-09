//
//  MokupClient.swift
//  PFXPlayer
//
//  Created by succorer on 21/01/2020.
//  Copyright © 2020 pfxstudio. All rights reserved.
//

import Foundation
import RxSwift

class MokupClient : ClientProtocol {
    var basePath: String = ""

    func requestMusicModel() -> Observable<MusicModel> {
        return Observable<MusicModel>.empty()
    }
    
}
