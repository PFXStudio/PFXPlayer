//
//  Client.swift
//  PFXPlayer
//
//  Created by succorer on 21/01/2020.
//  Copyright © 2020 pfxstudio. All rights reserved.
//

import Foundation
import RxSwift

public protocol ClientProtocol {
    var basePath: String { get set }
    func requestMusicModel() -> Observable<MusicModel>
}
