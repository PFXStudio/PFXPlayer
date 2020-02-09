//
//  ListLyricsViewController.swift
//  PFXPlayer
//
//  Created by succorer on 01/02/2020.
//  Copyright © 2020 PFXStudio. All rights reserved.
//

import Foundation
import UIKit
import RxDataSources
import RxSwift

class ListLyricsViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var disposeBag = DisposeBag()
    let viewModel = LyricsViewModel()
    var dataSource: RxTableViewSectionedReloadDataSource<LyricsModel>!
    var playModel = PlayModel(millisecond: 0, duration: 0, status: .stop)
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.bindTableViewDataSource()
        self.bindMusicPlayer()
        self.bindScale()
        self.bindFavorite()
        self.bindAutoScroll()
    }
    
    deinit {
        self.disposeBag = DisposeBag()
    }
}

extension ListLyricsViewController {
    func bindTableViewDataSource() {
        let (cell) = self.tableViewDataSouce()
        self.dataSource = RxTableViewSectionedReloadDataSource(configureCell: cell)
        self.viewModel.data.asObservable()
            .subscribeOn(MainScheduler.instance)
            .bind(to: self.tableView.rx.items(dataSource: self.dataSource))
            .disposed(by: self.disposeBag)
        
        self.tableView.rx.willBeginDragging
            .subscribe(onNext: { [weak self] _ in
                guard let weakSelf = self else {
                    return
                }
                
                weakSelf.viewModel.toggledAutoScroll(isAuto: false)
            }, onError: { error in
                    print(error)
            })
            .disposed(by: self.disposeBag)
        
        self.tableView.rx.itemSelected.asObservable()
            .subscribeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] indexPath in
                guard let weakSelf = self else {
                    return
                }
                
                if weakSelf.viewModel.favorite.value == indexPath.row {
                    weakSelf.viewModel.toggledFavorite(index: indexPath.row, isSelected: false)
                    weakSelf.tableView.deselectRow(at: indexPath, animated: true)
                    return
                }

                weakSelf.viewModel.toggledFavorite(index: indexPath.row, isSelected: true)
                weakSelf.tableView.deselectRow(at: indexPath, animated: true)
            }, onError: { error in
                    print(error)
            })
            .disposed(by: self.disposeBag)
        
        if self.viewModel.isMiniSize.value == false {
            self.tableView.isScrollEnabled = true
        }
    }
    
    func tableViewDataSouce() -> (TableViewSectionedDataSource<LyricsModel>.ConfigureCell) {
        return ( { (_, tb, ip, i) in
            let cell = tb.dequeueReusableCell(withIdentifier: String(describing: LyricsCell.self), for: ip) as! LyricsCell
            guard let viewModel = self.viewModel.data.value.first else {
                return cell
            }
            
            var item = viewModel.items[ip.row]
            item.scale = self.viewModel.scaleValue.value
            item.isFavorite = self.viewModel.favorite.value == ip.row ? true : false
            cell.updateControllers(item: item, isMiniSize: self.viewModel.isMiniSize.value, selectedFavoriteButton: { lyricsCellModel in
                
            })
            return cell
        })
    }
    
    func bindMusicPlayer() {
        MusicPlayer.shared.updateSubject
            .subscribeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] (playModel) in
                guard let weakSelf = self else {
                    return
                }
                
                weakSelf.playModel = playModel
                let index = MusicPlayer.shared.millisecondToIndex(millisecond: playModel.millisecond)
                let indexPath = IndexPath(row: index, section: 0)
                guard let cell = weakSelf.tableView.cellForRow(at: indexPath) as? LyricsCell else {
                    if weakSelf.viewModel.autoScroll.value == false {
                        return
                    }
                    
                    weakSelf.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
                    return
                }

                let oldIndexPath = IndexPath(row: index - 1, section: 0)
                if let oldCell = weakSelf.tableView.cellForRow(at: oldIndexPath) as? LyricsCell {
                    oldCell.nonFocus()
                }

                cell.focus()
                if weakSelf.viewModel.autoScroll.value == false {
                    return
                }
                
                weakSelf.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
            }, onError: { error in
                    print(error)
            })
            .disposed(by: self.disposeBag)
    }
    
    func bindScale() {
        self.viewModel.scaleValue.asObservable()
            .subscribeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] (value) in
                guard let weakSelf = self else {
                    return
                }
                
                weakSelf.tableView.reloadData()
            }, onError: { error in
                    print(error)
            })
            .disposed(by: self.disposeBag)
    }
    
    func bindFavorite() {
        self.viewModel.favorite.asObservable()
            .skip(1)
            .subscribeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] (value) in
                guard let weakSelf = self else {
                    return
                }
                
                weakSelf.viewModel.toggledAutoScroll(isAuto: false)
                weakSelf.tableView.reloadData()
            }, onError: { error in
                    print(error)
            })
            .disposed(by: self.disposeBag)
    }

    func bindAutoScroll() {
        self.viewModel.autoScroll.asObservable()
            .subscribeOn(MainScheduler.instance)
            .filter({_ in
                return self.playModel.status == .play
            })
            .filter({ (isAuto) -> Bool in
                return isAuto
            })
            .subscribe(onNext: { [weak self] (isAuto) in
                guard let weakSelf = self else {
                    return
                }
                
                let index = MusicPlayer.shared.millisecondToIndex(millisecond: weakSelf.playModel.millisecond)
                let indexPath = IndexPath(row: index, section: 0)
                weakSelf.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
            }, onError: { error in
                    print(error)
            })
            .disposed(by: self.disposeBag)
    }
}

extension ListLyricsViewController : MusicViewProtocal {
    func prePareViewsForUpdate(musicModel: MusicModel) {
        self.viewModel.update(items: musicModel.lyricsSyncs)
    }
}
