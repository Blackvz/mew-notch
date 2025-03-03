//
//  ClipboardManager.swift
//  MewNotch
//
//  Created by Monu Kumar on 04/03/25.
//

import Foundation
import AppKit

class ClipboardManager: ObservableObject {
    static let shared = ClipboardManager()
    
    @Published var clipboardItems: [ClipboardItem] = []
    private let maxItems = 10
    private var timer: Timer?
    private var lastChangeCount: Int = 0
    
    struct ClipboardItem: Identifiable, Equatable {
        let id = UUID()
        let text: String
        let timestamp: Date
        
        static func == (lhs: ClipboardItem, rhs: ClipboardItem) -> Bool {
            return lhs.text == rhs.text
        }
    }
    
    private init() {
        startMonitoring()
    }
    
    func startMonitoring() {
        // Get initial clipboard content
        checkClipboard()
        
        // Set up timer to check clipboard periodically
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.checkClipboard()
        }
    }
    
    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
    }
    
    private func checkClipboard() {
        let pasteboard = NSPasteboard.general
        let currentChangeCount = pasteboard.changeCount
        
        // Only process if the pasteboard has changed
        if currentChangeCount != lastChangeCount {
            lastChangeCount = currentChangeCount
            
            if let string = pasteboard.string(forType: .string), !string.isEmpty {
                addClipboardItem(string)
            }
        }
    }
    
    private func addClipboardItem(_ text: String) {
        // Create new item
        let newItem = ClipboardItem(text: text, timestamp: Date())
        
        // Remove duplicate if exists
        clipboardItems.removeAll(where: { $0.text == text })
        
        // Add new item at the beginning
        clipboardItems.insert(newItem, at: 0)
        
        // Limit the number of items
        if clipboardItems.count > maxItems {
            clipboardItems = Array(clipboardItems.prefix(maxItems))
        }
    }
    
    func copyToClipboard(_ text: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
    }
}
