//
//  NetworkClient.swift
//  PFXPlayer
//
//  Created by succorer on 21/01/2020.
//  Copyright © 2020 pfxstudio. All rights reserved.
//

import Foundation
import RxSwift
import RxAlamofire
import Alamofire

extension ObservableType {
    
    public func mapObject<T: Codable>(type: T.Type) -> Observable<T> {
        return flatMap { data -> Observable<T> in
            let responseTuple = data as? (HTTPURLResponse, Data)

            guard let jsonData = responseTuple?.1 else {
                throw NSError(
                    domain: "",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "Could not decode object"]
                )
            }
            
            let decoder = JSONDecoder()
            let object = try decoder.decode(T.self, from: jsonData)
            
            return Observable.just(object)
        }
    }
    
    public func mapArray<T: Codable>(type: T.Type) -> Observable<[T]> {
        return flatMap { data -> Observable<[T]> in
            let responseTuple = data as? (HTTPURLResponse, Data)
            
            guard let jsonData = responseTuple?.1 else {
                throw NSError(
                    domain: "",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "Could not decode object"]
                )
            }
            
            let decoder = JSONDecoder()
            let objects = try decoder.decode([T].self, from: jsonData)
            
            return Observable.just(objects)
        }
    }
}

class NetworkClient : ClientProtocol {
    var disposeBag = DisposeBag()
    var basePath: String = "https://grepp-programmers-challenges.s3.ap-northeast-2.amazonaws.com/2020-flo/song.json"
    
    func requestMusicModel() -> Observable<MusicModel> {
        RxAlamofire.requestData(.get, URL(string: self.basePath)!, parameters: nil, headers: nil)
            .mapObject(type: MusicModel.self)
    }
    
    func requestMusicDownload(url: URL) -> Observable<Data?> {
        RxAlamofire
        .requestData(.get, url)
        .map({ (response, data) -> Data? in
            if response.statusCode != 200 {
                return nil
            }
            
            return data
        })
    }
    
    deinit {
        self.disposeBag = DisposeBag()
    }
}
