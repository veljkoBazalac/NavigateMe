//
//  UIImage.swift
//  NavigateMe
//
//  Created by Veljko Bažalac on 30.1.23..
//

import UIKit
import CoreLocation

extension FloatingPoint {
    var degreesToRadians: Self { return self * .pi / 180 }
    var radiansToDegrees: Self { return self * 180 / .pi }
}

extension CLLocationCoordinate2D {
    func heading(to: CLLocationCoordinate2D) -> Double {
        let lat1 = self.latitude.degreesToRadians
        let lon1 = self.longitude.degreesToRadians
        
        let lat2 = to.latitude.degreesToRadians
        let lon2 = to.longitude.degreesToRadians
        
        let dLon = lon2 - lon1
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        
        let headingDegrees = atan2(y, x).radiansToDegrees
        
        if headingDegrees >= 0 {
            return headingDegrees
        } else {
            return headingDegrees + 360
        }
    }
}
