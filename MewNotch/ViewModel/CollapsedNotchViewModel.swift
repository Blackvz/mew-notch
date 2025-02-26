//
//  CollapsedNotchViewModel.swift
//  MewNotch
//
//  Created by Monu Kumar on 26/02/25.
//

import SwiftUI

class CollapsedNotchViewModel: ObservableObject {
    
    @Published var notchSize: CGSize = .zero
    var extraNotchPadSize: CGSize = .init(
        width: 13,
        height: 0
    )
    
    @Published var hudIcon: Image?
    @Published var hudValue: Float?
    @Published var hudTimer: Timer?
    @Published var hudRefreshTimer: Timer?
    
    init() {
        self.notchSize = NotchUtils.shared.notchSize(
            screen: NSScreen.main,
            force: true
        )
        
        withAnimation {
            notchSize.width += extraNotchPadSize.width
            notchSize.height += extraNotchPadSize.height
        }
        
        self.startListeners()
    }
    
    func startListeners() {
        self.startListeningForVolumeChanges()
        self.startListeningForBrightnessChanges()
    }
    
    func stopListeners() {
        NotificationCenter.default.removeObserver(self)
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
        
        withAnimation {
            hudIcon = Image(
                systemName: "speaker"
            )
            
            hudValue = VolumeManager.shared.getOutputVolume()
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
                self.hudValue = VolumeManager.shared.getOutputVolume()
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
        withAnimation {
            hudIcon = Image(
                systemName: "rays"
            )
            
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
