//
//  AlertView.swift
//  NavigateMe
//
//  Created by Veljko Bažalac on 28.1.23..
//

import UIKit

class AlertView {
    
    static let shared = AlertView()
    
    func addAlert(vc: UIViewController, title: String, body: String) {
        let alert = UIAlertController(title: title, message: body, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel)
        alert.addAction(action)
        vc.present(alert, animated: true)
    }
}
