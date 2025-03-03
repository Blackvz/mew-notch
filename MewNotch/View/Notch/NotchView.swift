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
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                
                ZStack(alignment: .top) {
                    CollapsedNotchView(
                        isHovered: isHovered
                    )
                    .onHover { isHovered in
                        withAnimation {
                            self.isHovered = isHovered
                        }
                    }
                    
                    if isHovered && !clipboardManager.clipboardItems.isEmpty {
                        ClipboardHistoryView()
                            .offset(y: 30) // Position below the notch
                            .transition(.opacity)
                            .zIndex(100)
                    }
                }
                    
                
                Spacer()
            }
            
            Spacer()
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
