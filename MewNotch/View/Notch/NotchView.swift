//
//  NotchView.swift
//  MewNotch
//
//  Created by Monu Kumar on 25/02/25.
//

import SwiftUI

struct NotchView: View {
    
    @Namespace var nameSpace
    
    @State var isHovered: Bool = false
    @State var isExpanded: Bool = false
    
    @State var timer: Timer? = nil
    @State var isHoveringClipboard: Bool = false
    
    @ObservedObject private var clipboardManager = ClipboardManager.shared
    
    // We'll use onAppear instead of init for notification setup
    
    var body: some View {
        ZStack(alignment: .top) {
            // Main content
            VStack {
                HStack {
                    Spacer()
                    
                    CollapsedNotchView(
                        isHovered: isHovered
                    )
                    .onHover { hovering in
                        print("Notch hover state changed to: \(hovering)")
                        print("Current clipboard items: \(clipboardManager.clipboardItems.count)")
                        
                        if hovering {
                            // When hovering starts, update immediately
                            withAnimation(.easeInOut(duration: 0.2)) {
                                self.isHovered = true
                            }
                        } else {
                            // When hover ends, delay closing to allow moving to clipboard menu
                            // Cancel any existing timer
                            timer?.invalidate()
                            
                            // Create new timer with short delay
                            timer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { _ in
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    self.isHovered = false
                                }
                            }
                        }
                    }
                    
                    Spacer()
                }
                
                Spacer()
            }
            
            // Clipboard history overlay
            if isHovered && !clipboardManager.clipboardItems.isEmpty {
                VStack {
                    HStack {
                        Spacer()
                        ClipboardHistoryView()
                            .offset(y: 40) // Position below the notch
                            .onHover { hovering in
                                // When hovering over clipboard history
                                if hovering {
                                    // Cancel any existing timer to close
                                    timer?.invalidate()
                                    
                                    // Keep menu open
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        self.isHovered = true
                                    }
                                } else {
                                    // When hover ends on clipboard history, start timer to close
                                    timer?.invalidate()
                                    timer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { _ in
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            self.isHovered = false
                                        }
                                    }
                                }
                            }
                        Spacer()
                    }
                    Spacer()
                }
                .transition(.opacity)
            }
        }
        .onAppear {
            // Set up notification observer for clipboard menu close
            NotificationCenter.default.addObserver(
                forName: .closeClipboardMenu,
                object: nil,
                queue: .main
            ) { _ in
                // Use DispatchQueue to update the state on the main thread
                DispatchQueue.main.async {
                    withAnimation {
                        isHovered = false
                    }
                }
            }
        }
        .onDisappear {
            // Remove observer when view disappears
            NotificationCenter.default.removeObserver(self)
            timer?.invalidate()
        }
        .contextMenu(
            menuItems: {
                
                SettingsLink {
                    Text("Settings")
                }
                .keyboardShortcut(
                    ",",
                    modifiers: .command
                )
                
                Button("Restart") {
                    guard let bundleIdentifier = Bundle.main.bundleIdentifier else {
                        return
                    }
                    
                    let workspace = NSWorkspace.shared
                    
                    if let appURL = workspace.urlForApplication(
                        withBundleIdentifier: bundleIdentifier
                    ) {
                        let configuration = NSWorkspace.OpenConfiguration()
                        
                        configuration.createsNewApplicationInstance = true
                        
                        workspace.openApplication(
                            at: appURL,
                            configuration: configuration
                        )
                    }
                
                   NSApplication.shared.terminate(nil)
                }
                .keyboardShortcut("R", modifiers: .command)
                
                Divider()
                
                Button("Test Volume HUD") {
                    NotificationManager.triggerVolumeNotification()
                }
                
                Button("Test Brightness HUD") {
                    NotificationManager.triggerBrightnessNotification()
                }
                
                Button("Debug Clipboard") {
                    print("Current clipboard items: \(clipboardManager.clipboardItems.count)")
                    for (index, item) in clipboardManager.clipboardItems.enumerated() {
                        print("Item \(index): \(item.text.prefix(30))...")
                    }
                }
                
                Divider()
                
                Button(
                    "Quit",
                    role: .destructive
                ) {
                    NSApplication.shared.terminate(nil)
                }
                .keyboardShortcut(
                    "Q",
                    modifiers: .command
                )
            }
        )
    }
}

#Preview {
    NotchView()
}
