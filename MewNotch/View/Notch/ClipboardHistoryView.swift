//
//  ClipboardHistoryView.swift
//  MewNotch
//
//  Created by Monu Kumar on 04/03/25.
//

import SwiftUI

struct ClipboardHistoryView: View {
    @StateObject private var clipboardManager = ClipboardManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Clipboard History")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 10)
                .padding(.top, 10)
                .padding(.bottom, 5)
            
            Divider()
                .background(Color.white.opacity(0.3))
            
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(clipboardManager.clipboardItems) { item in
                        ClipboardItemView(item: item)
                    }
                }
            }
            .frame(maxHeight: 300)
        }
        .frame(width: 300)
        .background(Color.black.opacity(0.9))
        .cornerRadius(10)
        .shadow(radius: 5)
        .padding(.top, 5)
        .animation(.easeInOut, value: clipboardManager.clipboardItems.count)
    }
}

struct ClipboardItemView: View {
    let item: ClipboardManager.ClipboardItem
    @State private var isHovered = false
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(item.text)
                .lineLimit(2)
                .font(.system(size: 14))
                .foregroundColor(.white)
            
            Text(timeAgo(from: item.timestamp))
                .font(.system(size: 10))
                .foregroundColor(.gray)
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(isHovered ? Color.gray.opacity(0.3) : Color.clear)
        .cornerRadius(5)
        .onHover { hovering in
            isHovered = hovering
        }
        .onTapGesture {
            ClipboardManager.shared.copyToClipboard(item.text)
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
