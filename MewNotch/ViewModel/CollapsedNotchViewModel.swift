//
//  CollapsedNotchViewModel.swift
//  MewNotch
//
//  Created by Monu Kumar on 26/02/25.
//

import SwiftUI

class CollapsedNotchViewModel: ObservableObject {
    // Clipboard history state
    @Published var showClipboardHistory: Bool = false
    
    @Published var notchSize: CGSize = .zero
    var extraNotchPadSize: CGSize = .init(
        width: 14,
        height: 0
    )
    
    @Published var hudIcon: Image?
    @Published var hudValue: Float?
    @Published var hudTimer: Timer?
    @Published var hudRefreshTimer: Timer?
    
    init() {
        self.notchSize = NotchUtils.shared.notchSize(
            screen: NSScreen.main,
            force: MewDefaultsManager.shared.notchForceEnabled
        )
        
        withAnimation {
            notchSize.width += extraNotchPadSize.width
            notchSize.height += extraNotchPadSize.height
        }
        
        self.startListeners()
        
        // Start clipboard monitoring
        DispatchQueue.main.async {
            ClipboardManager.shared.startMonitoring()
            print("Clipboard monitoring started")
        }
    }
    
    func refreshNotchSize() {
        self.notchSize = NotchUtils.shared.notchSize(
            screen: NSScreen.main,
            force: MewDefaultsManager.shared.notchForceEnabled
        )
        
        withAnimation {
            notchSize.width += extraNotchPadSize.width
            notchSize.height += extraNotchPadSize.height
        }
    }
    
    func startListeners() {
        self.startListeningForVolumeChanges()
        self.startListeningForBrightnessChanges()
    }
    
    func stopListeners() {
        NotificationCenter.default.removeObserver(self)
        ClipboardManager.shared.stopMonitoring()
    }
    
    private func startListeningForVolumeChanges() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleVolumeChanges),
            name: NotificationManager.volumeChangedNotification,
            object: nil
        )
    }
    
    private func startListeningForBrightnessChanges() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleBrightnessChanges),
            name: NotificationManager.brightnessChangedNotification,
            object: nil
        )
    }
    
    @objc private func handleVolumeChanges() {
        NSLog("Volume change notification received")
        
        if !MewDefaultsManager.shared.hudEnabled {
            NSLog("HUD is disabled in settings, not showing volume indicator")
            return
        }
        
        NSLog("Showing volume HUD")
        withAnimation {
            hudIcon = MewNotch.Assets.iconSpeaker
            
            if VolumeManager.shared.isMuted() {
                NSLog("System is muted, setting volume to 0")
                self.hudValue = 0.0
            } else {
                let volume = VolumeManager.shared.getOutputVolume()
                NSLog("Current volume: \(volume)")
                self.hudValue = volume
            }
        }
        
        var counter = 0
        
        hudRefreshTimer?.invalidate()
        hudRefreshTimer = Timer.scheduledTimer(
            withTimeInterval: 0.1,
            repeats: true
        ) { timer in
            if counter == 10 {
                timer.invalidate()
            }
            
            counter += 1
            
            withAnimation {
                if VolumeManager.shared.isMuted() {
                    self.hudValue = 0.0
                } else {
                    self.hudValue = VolumeManager.shared.getOutputVolume()
                }
            }
        }
        
        hudTimer?.invalidate()
        hudTimer = .scheduledTimer(
            withTimeInterval: 1.5,
            repeats: false
        ) { _ in
            withAnimation {
                self.hudIcon = nil
                self.hudValue = nil
            }
        }
    }
    
    @objc private func handleBrightnessChanges() {
        if !MewDefaultsManager.shared.hudEnabled {
            return
        }
        
        withAnimation {
            hudIcon = MewNotch.Assets.iconBrightness
            
            hudValue = try? DisplayManager.shared.getDisplayBrightness()
        }
        
        var counter = 0
        
        hudRefreshTimer?.invalidate()
        hudRefreshTimer = Timer.scheduledTimer(
            withTimeInterval: 0.1,
            repeats: true
        ) { timer in
            if counter == 10 {
                timer.invalidate()
            }
            
            counter += 1
            
            withAnimation {
                self.hudValue = try? DisplayManager.shared.getDisplayBrightness()
            }
        }
        
        hudTimer?.invalidate()
        hudTimer = .scheduledTimer(
            withTimeInterval: 1.5,
            repeats: false
        ) { _ in
            withAnimation {
                self.hudIcon = nil
                self.hudValue = nil
            }
        }
    }
}
