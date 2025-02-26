//
//  MewWindow.swift
//  MewNotch
//
//  Created by Monu Kumar on 25/02/25.
//

import SwiftUI

class MewPanel: NSPanel {
    
    override init(
        contentRect: NSRect,
        styleMask: NSWindow.StyleMask,
        backing: NSWindow.BackingStoreType,
        defer flag: Bool
    ) {
        super.init(
            contentRect: contentRect,
            styleMask: styleMask,
            backing: backing,
            defer: flag
        )
        
        isFloatingPanel = true
        isOpaque = false
        titleVisibility = .hidden
        titlebarAppearsTransparent = true
        backgroundColor = .clear
        isMovable = false
        
        collectionBehavior = [
            .fullScreenAuxiliary,
            .stationary,
            .canJoinAllSpaces,
            .ignoresCycle,
        ]
        
        isReleasedWhenClosed = false
        level = .mainMenu + 3
        hasShadow = true
    }
    
    override var canBecomeKey: Bool {
        false
    }
    
    override var canBecomeMain: Bool {
        false
    }
}
