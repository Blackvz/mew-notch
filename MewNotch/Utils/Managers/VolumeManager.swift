//
//  VolumeManager.swift
//  MewNotch
//
//  Created by Monu Kumar on 26/02/25.
//

import AppKit

class VolumeManager {
    
    static let shared = VolumeManager()
    
    private init() {}

    func isMuted() -> Bool {
        do {
            let result = try AppleScriptRunner.shared.run(
                script: "return output muted of (get volume settings)"
            )
            NSLog("Mute check result: \(result)")
            return result == "true"
        } catch {
            NSLog(
                "Error while trying to retrieve muted properties of device: \(error). Returning default value false."
            )
            
            return false
        }
    }

    func getOutputVolume() -> Float {
        do {
            let scriptResult = try AppleScriptRunner.shared.run(
                script: "return output volume of (get volume settings)"
            )
            NSLog("Volume AppleScript result: \(scriptResult)")
            
            if let volumeStr = Float(scriptResult) {
                let normalizedVolume = volumeStr / 100
                NSLog("Normalized volume: \(normalizedVolume)")
                return normalizedVolume
            } else {
                NSLog(
                    "Error while trying to parse volume string value. Returning default volume value 0.01."
                )
            }
        } catch {
            NSLog(
                "Error while trying to retrieve volume properties of device: \(error). Returning default volume value 0.01."
            )
        }
        
        return 0.01
    }
}
