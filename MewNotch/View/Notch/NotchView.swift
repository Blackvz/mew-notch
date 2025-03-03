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
    
    @ObservedObject private var clipboardManager = ClipboardManager.shared
    
    init() {
        // Register for clipboard menu close notification
        NotificationCenter.default.addObserver(
            forName: .closeClipboardMenu,
            object: nil,
            queue: .main
        ) { _ in
            withAnimation {
                self.isHovered = false
            }
        }
    }
    
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
                        withAnimation(.easeInOut(duration: 0.2)) {
                            self.isHovered = hovering
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
                                // Keep the hover state true when hovering over the clipboard history
                                if hovering {
                                    self.isHovered = true
                                }
                            }
                        Spacer()
                    }
                    Spacer()
                }
                .transition(.opacity)
            }
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
