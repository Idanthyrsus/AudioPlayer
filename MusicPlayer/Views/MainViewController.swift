//
//  ViewController.swift
//  MusicPlayer
//
//  Created by Alexander Korchak on 27.05.2023.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit


class MainViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    private let viewModel = MainViewModel()
    var position: Int = 0
    
    private lazy var table: UITableView =  {
        let table = UITableView(frame: .zero, style: .plain)
        table.backgroundColor = UIColor.theme.background
        table.rowHeight = 40
        table.register(CustomCell.self, forCellReuseIdentifier: CustomCell.reuseIdentifier)
        return table
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.theme.background
        setupTableView()
        bindTableView()
        showPlayerViewController()
    }
    
    private func setupTableView() {
        view.addSubview(table)
        
        table.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.bottom.leading.trailing.equalToSuperview()
        }
    }
    
    private func bindTableView() {
        viewModel.tracks
            .bind(to: table
                .rx
                .items(cellIdentifier: CustomCell.reuseIdentifier,
                       cellType: CustomCell.self)) { indexPath, title, cell  in
                
                cell.apply(bandName: title.bandName,
                           trackName: title.trackName,
                           time: title.time)
                
            }
            .disposed(by: disposeBag)
    }
    
    func showPlayerViewController() {
        
        Observable.zip(table.rx.itemSelected,
                       table.rx.modelSelected(Track.self)).bind {
            [weak self] indexPath, track in
            guard let self = self else { return }
           
            self.position = indexPath.row
            
            let playerViewController = PlayerViewController()
            playerViewController.trackName.accept(track.trackName)
            playerViewController.bandName.accept(track.bandName)
            
            playerViewController.position.accept(self.position)
            self.present(playerViewController, animated: true)
            
          }.disposed(by: disposeBag)
    }
}

