//
//  HapticManager.swift
//  NavigateMe
//
//  Created by Veljko Bažalac on 31.1.23..
//

import UIKit

class HapticManager {
    
    static let shared = HapticManager()
    
    func vibration(type: Vibration) {
        let generatorType     = UINotificationFeedbackGenerator()
        let generatorStyle    = UIImpactFeedbackGenerator(style: type.vibrationStyle)
        generatorType.notificationOccurred(type.vibrationType)
        generatorStyle.impactOccurred()
    }
    
    enum Vibration {
        case success
        case warning
        case error
        
        var vibrationType: UINotificationFeedbackGenerator.FeedbackType {
            switch self {
            case .success:    return .success
            case .warning:    return .warning
            case .error:      return .error
            }
        }
        
        var vibrationStyle: UIImpactFeedbackGenerator.FeedbackStyle {
            switch self {
            case .success:    return .medium
            case .warning:    return .soft
            case .error:      return .heavy
            }
        }
    }
}
