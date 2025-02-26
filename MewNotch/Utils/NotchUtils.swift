//
//  NotchUtils.swift
//  MewNotch
//
//  Created by Monu Kumar on 25/02/25.
//

import AppKit

class NotchUtils {
    
    static let shared = NotchUtils()
    
    private init() { }
    
    func hasNotch(
        screen: NSScreen
    ) -> Bool {
        return screen.safeAreaInsets.top > 0
    }
    
    func notchSize(
        screen: NSScreen? = nil,
        force: Bool = false
    ) -> CGSize {
        guard let screen = screen else {
            return .zero
        }
        
        if !hasNotch(
            screen: screen
        ) {
            if !force {
                return .zero
            }
            
            return getSimulatedNotchSize(
                screen: screen
            )
        }
        
        return getRealNotchSize(
            screen: screen
        )
    }
    
    private func getRealNotchSize(
        screen: NSScreen
    ) -> CGSize {
        var notchWidth: CGFloat = 0
        var notchHeight: CGFloat = 0

        if let topLeftSpace: CGFloat = screen.auxiliaryTopLeftArea?.width, let topRightSpace: CGFloat = screen.auxiliaryTopRightArea?.width {
            notchWidth = screen.frame.width - topLeftSpace - topRightSpace
        }
        
        notchHeight = screen.safeAreaInsets.top

        return .init(
            width: notchWidth,
            height: notchHeight
        )
    }
    
    private func getSimulatedNotchSize(
        screen: NSScreen
    ) -> CGSize {
        var notchWidth: CGFloat = 180
        var notchHeight: CGFloat = 0

        if let topLeftSpace: CGFloat = screen.auxiliaryTopLeftArea?.width, let topRightSpace: CGFloat = screen.auxiliaryTopRightArea?.width {
            notchWidth = screen.frame.width - topLeftSpace - topRightSpace
        }
        
        notchHeight = screen.frame.maxY - screen.visibleFrame.maxY

        return .init(
            width: notchWidth,
            height: notchHeight
        )
    }
}
