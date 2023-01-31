//
//  UIView.swift
//  NavigateMe
//
//  Created by Veljko Bažalac on 30.1.23..
//

import UIKit

extension UIView {
    func dropShadow(color:   UIColor    = .black,
                   offset:   CGSize     = CGSize(width: 0, height: 4),
                   radius:   CGFloat    = 4,
                   opacity:  Float      = 0.5) {
        layer.masksToBounds  = false
        layer.shadowOffset   = offset
        layer.shadowColor    = color.cgColor
        layer.shadowRadius   = radius
        layer.shadowOpacity  = opacity
        
        let backgroundCGColor = backgroundColor?.cgColor
        backgroundColor       = nil
        layer.backgroundColor = backgroundCGColor
    }
}
