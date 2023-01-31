//
//  CGFloat.swift
//  NavigateMe
//
//  Created by Veljko Bažalac on 30.1.23..
//

import Foundation

public extension CGFloat {
    var toRadians: CGFloat { return self * .pi / 180 }
    var toDegrees: CGFloat { return self * 180 / .pi }
}
