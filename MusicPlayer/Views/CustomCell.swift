//
//  CustomCell.swift
//  MusicPlayer
//
//  Created by Alexander Korchak on 27.05.2023.
//

import Foundation
import UIKit
import SnapKit

class CustomCell: UITableViewCell {
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.theme.accent
        label.backgroundColor = UIColor.theme.background
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        return label
    }()
    
    private lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.theme.accent
        label.backgroundColor = UIColor.theme.background
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        return label
    }()
    
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
       
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.backgroundColor = UIColor.theme.background
        setupContent()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupContent() {
        contentView.addSubview(nameLabel)
        contentView.addSubview(timeLabel)
        
        nameLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(3)
            make.bottom.equalToSuperview().offset(-3)
        }
        
        timeLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(3)
            make.bottom.equalToSuperview().offset(-3)
        }
    }
    
    func apply(bandName: String, trackName: String, time: String) {
        nameLabel.text = bandName.replacingOccurrences(of: "-", with: " ").capitalized + " - " + trackName.replacingOccurrences(of: "-", with: " ").capitalized
        timeLabel.text = time
    }
}
