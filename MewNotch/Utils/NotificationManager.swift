//
//  NotificationManager.swift
//  MewNotch
//
//  Created by Monu Kumar on 25/02/25.
//

import Foundation

class NotificationManager {
    
    static let volumeChangedNotification = Notification.Name("MewNotch.volumeChangedNotification")
    static let brightnessChangedNotification = Notification.Name("MewNotch.brightnessChangedNotification")
    static let backlightChangedNotification = Notification.Name("MewNotch.backlightChangedNotification")
    
    static let shared = NotificationManager()
    
    private init() { }
    
    func postVolumeChanged() {
        NSLog("Posting volume changed notification")
        NotificationCenter.default.post(
            name: Self.volumeChangedNotification,
            object: self
        )
    }
    
    func postBrightnessChanged() {
        NSLog("Posting brightness changed notification")
        NotificationCenter.default.post(
            name: Self.brightnessChangedNotification,
            object: self
        )
    }
    
    func postBacklightChanged() {
        NSLog("Posting backlight changed notification")
        NotificationCenter.default.post(
            name: Self.backlightChangedNotification,
            object: self
        )
    }
    
    // Helper method for testing
    static func triggerVolumeNotification() {
        NSLog("Manually triggering volume notification")
        shared.postVolumeChanged()
    }
    
    // Helper method for testing
    static func triggerBrightnessNotification() {
        NSLog("Manually triggering brightness notification")
        shared.postBrightnessChanged()
    }
}
