//
//  AlertManager.swift
//  NavigateMe
//
//  Created by Veljko Bažalac on 28.1.23..
//

import UIKit

class AlertManager {
    
    static let shared = AlertManager()
    
    func addOKAlert(vc: UIViewController, title: String, body: String) {
        let alert = UIAlertController(title: title, message: body, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel)
        alert.addAction(action)
        vc.present(alert, animated: true)
    }
    
    func addEnableLocationAlert(vc: UIViewController) {
        let alert = UIAlertController(title: "Location Disabled", message: "Please enable Your location services.", preferredStyle: .alert)
        let goToSettingsAction = UIAlertAction(title: "Go To Settings", style: .default) { _ in
            // Go to Settings
            if let bundleId = Bundle.main.bundleIdentifier,
               let url = URL(string: "\(UIApplication.openSettingsURLString)&path=LOCATION/\(bundleId)") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel)
        alert.addAction(goToSettingsAction)
        alert.addAction(dismissAction)
        vc.present(alert, animated: true)
    }
}
