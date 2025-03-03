//
//  ClipboardHistoryView.swift
//  MewNotch
//
//  Created by Monu Kumar on 04/03/25.
//

import SwiftUI

struct ClipboardHistoryView: View {
    @ObservedObject private var clipboardManager = ClipboardManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Clipboard History")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("Click to copy")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 10)
            .padding(.top, 10)
            .padding(.bottom, 5)
            
            Divider()
                .background(Color.white.opacity(0.3))
            
            if clipboardManager.clipboardItems.isEmpty {
                Text("No clipboard items")
                    .foregroundColor(.gray)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 2) {
                        ForEach(clipboardManager.clipboardItems) { item in
                            ClipboardItemView(item: item)
                        }
                    }
                }
                .frame(maxHeight: 300)
            }
        }
        .frame(width: 300)
        .background(Color.black.opacity(0.95))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: .white.opacity(0.3), radius: 5)
    }
}

struct ClipboardItemView: View {
    let item: ClipboardManager.ClipboardItem
    @State private var isHovered = false
    @State private var isCopied = false
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(item.text)
                .lineLimit(2)
                .font(.system(size: 14))
                .foregroundColor(.white)
            
            HStack {
                Text(timeAgo(from: item.timestamp))
                    .font(.system(size: 10))
                    .foregroundColor(.gray)
                
                Spacer()
                
                if isCopied {
                    Text("Copied!")
                        .font(.system(size: 10))
                        .foregroundColor(.green)
                        .transition(.opacity)
                }
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(isHovered ? Color.gray.opacity(0.3) : Color.clear)
        .cornerRadius(5)
        .onHover { hovering in
            isHovered = hovering
        }
        .onTapGesture {
            copyItemToClipboard()
        }
    }
    
    private func copyItemToClipboard() {
        ClipboardManager.shared.copyToClipboard(item.text)
        
        // Show copied indicator
        withAnimation {
            isCopied = true
        }
        
        // Hide copied indicator after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                isCopied = false
            }
        }
    }
    
    private func timeAgo(from date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.minute, .hour, .day], from: date, to: now)
        
        if let day = components.day, day > 0 {
            return "\(day) day\(day == 1 ? "" : "s") ago"
        } else if let hour = components.hour, hour > 0 {
            return "\(hour) hour\(hour == 1 ? "" : "s") ago"
        } else if let minute = components.minute, minute > 0 {
            return "\(minute) minute\(minute == 1 ? "" : "s") ago"
        } else {
            return "Just now"
        }
    }
}

#Preview {
    ClipboardHistoryView()
        .frame(width: 300, height: 400)
        .background(Color.gray)
}
