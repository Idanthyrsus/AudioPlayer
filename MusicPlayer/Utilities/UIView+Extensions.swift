//
//  UIView+Extensions.swift
//  MusicPlayer
//
//  Created by Alexander Korchak on 27.05.2023.
//

import Foundation
import UIKit

extension UIView {
    
    func addSubviews(_ subviews: [UIView]) {
        subviews.forEach(self.addSubview)
    }
}
