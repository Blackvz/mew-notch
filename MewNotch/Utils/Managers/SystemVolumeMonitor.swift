//
//  SystemVolumeMonitor.swift
//  MewNotch
//
//  Created by Claude on 04/03/25.
//

import Foundation
import CoreAudio

class SystemVolumeMonitor {
    static let shared = SystemVolumeMonitor()
    
    private var defaultOutputDevicePropertyListener: AudioObjectPropertyListenerProc?
    private var volumePropertyListener: AudioObjectPropertyListenerProc?
    private var mutedPropertyListener: AudioObjectPropertyListenerProc?
    
    private var defaultOutputDeviceID: AudioDeviceID = 0
    
    private init() {
        defaultOutputDevicePropertyListener = { (_, _, _, _) -> OSStatus in
            NSLog("Default output device changed")
            SystemVolumeMonitor.shared.setupVolumeListener()
            return noErr
        }
        
        volumePropertyListener = { (_, _, _, _) -> OSStatus in
            NSLog("Volume changed via system")
            DispatchQueue.main.async {
                NotificationManager.shared.postVolumeChanged()
            }
            return noErr
        }
        
        mutedPropertyListener = { (_, _, _, _) -> OSStatus in
            NSLog("Mute state changed via system")
            DispatchQueue.main.async {
                NotificationManager.shared.postVolumeChanged()
            }
            return noErr
        }
    }
    
    func startMonitoring() {
        NSLog("Starting system volume monitoring")
        setupDefaultOutputDeviceListener()
        setupVolumeListener()
    }
    
    func stopMonitoring() {
        NSLog("Stopping system volume monitoring")
        removeDefaultOutputDeviceListener()
        removeVolumeListener()
    }
    
    private func setupDefaultOutputDeviceListener() {
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultOutputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        
        let status = AudioObjectAddPropertyListener(
            AudioObjectID(kAudioObjectSystemObject),
            &propertyAddress,
            defaultOutputDevicePropertyListener,
            nil
        )
        
        if status != noErr {
            NSLog("Error setting up default output device listener: \(status)")
        }
    }
    
    private func removeDefaultOutputDeviceListener() {
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultOutputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        
        AudioObjectRemovePropertyListener(
            AudioObjectID(kAudioObjectSystemObject),
            &propertyAddress,
            defaultOutputDevicePropertyListener,
            nil
        )
    }
    
    private func setupVolumeListener() {
        // Get the default output device
        var propertySize = UInt32(MemoryLayout<AudioDeviceID>.size)
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultOutputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        
        let status = AudioObjectGetPropertyData(
            AudioObjectID(kAudioObjectSystemObject),
            &propertyAddress,
            0,
            nil,
            &propertySize,
            &defaultOutputDeviceID
        )
        
        if status != noErr {
            NSLog("Error getting default output device: \(status)")
            return
        }
        
        // Setup volume change listener
        propertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyVolumeScalar,
            mScope: kAudioDevicePropertyScopeOutput,
            mElement: kAudioObjectPropertyElementMain
        )
        
        if AudioObjectHasProperty(defaultOutputDeviceID, &propertyAddress) {
            let volumeStatus = AudioObjectAddPropertyListener(
                defaultOutputDeviceID,
                &propertyAddress,
                volumePropertyListener,
                nil
            )
            
            if volumeStatus != noErr {
                NSLog("Error setting up volume listener: \(volumeStatus)")
            }
        }
        
        // Setup mute change listener
        propertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyMute,
            mScope: kAudioDevicePropertyScopeOutput,
            mElement: kAudioObjectPropertyElementMain
        )
        
        if AudioObjectHasProperty(defaultOutputDeviceID, &propertyAddress) {
            let muteStatus = AudioObjectAddPropertyListener(
                defaultOutputDeviceID,
                &propertyAddress,
                mutedPropertyListener,
                nil
            )
            
            if muteStatus != noErr {
                NSLog("Error setting up mute listener: \(muteStatus)")
            }
        }
    }
    
    private func removeVolumeListener() {
        if defaultOutputDeviceID == 0 {
            return
        }
        
        // Remove volume change listener
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyVolumeScalar,
            mScope: kAudioDevicePropertyScopeOutput,
            mElement: kAudioObjectPropertyElementMain
        )
        
        if AudioObjectHasProperty(defaultOutputDeviceID, &propertyAddress) {
            AudioObjectRemovePropertyListener(
                defaultOutputDeviceID,
                &propertyAddress,
                volumePropertyListener,
                nil
            )
        }
        
        // Remove mute change listener
        propertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyMute,
            mScope: kAudioDevicePropertyScopeOutput,
            mElement: kAudioObjectPropertyElementMain
        )
        
        if AudioObjectHasProperty(defaultOutputDeviceID, &propertyAddress) {
            AudioObjectRemovePropertyListener(
                defaultOutputDeviceID,
                &propertyAddress,
                mutedPropertyListener,
                nil
            )
        }
    }
}
