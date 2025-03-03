//
//  CollapsedNotchView.swift
//  MewNotch
//
//  Created by Monu Kumar on 26/02/25.
//

import SwiftUI

struct CollapsedNotchView: View {
    
    @StateObject private var notchViewModel = CollapsedNotchViewModel.init()
    
    @StateObject var defaultsManager = MewDefaultsManager.shared
    
    var isHovered: Bool = false
    
    var body: some View {
        VStack(
            spacing: 0
        ) {
            HStack(
                spacing: 0
            ) {
                if defaultsManager.hudStyle == .Minimal {
                    if let hudIcon = notchViewModel.hudIcon {
                        Text(
                            "000 %"
                        )
                        .font(.title3.bold())
                        .frame(
                            height: notchViewModel.notchSize.height
                        )
                        .opacity(0)
                        .overlay {
                            hudIcon
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .foregroundStyle(Color.white)
                                .padding(8)
                        }
                        .padding(
                            .leading,
                            notchViewModel.extraNotchPadSize.width / 2
                        )
                        .transition(
                            .offset(
                                x: notchViewModel.extraNotchPadSize.width / 2
                            )
                            .combined(
                                with: .opacity
                            )
                        )
                    }
                }
                
                OnlyNotchView(
                    notchSize: notchViewModel.notchSize
                )
                
                if defaultsManager.hudStyle == .Minimal {
                    if let hudValue = notchViewModel.hudValue {
                        Text(
                            "000%"
                        )
                        .font(.title3.bold())
                        .frame(
                            height: notchViewModel.notchSize.height
                        )
                        .opacity(0)
                        .overlay {
                            AnimatedTextView(
                                value: Double(hudValue * 100)
                            ) { value in
                                Text(
                                    String(
                                        format: "%02.0f",
                                        value
                                    )
                                )
                                .font(.title3.bold())
                                .foregroundStyle(Color.white)
                            }
                        }
                        .padding(
                            .trailing,
                            notchViewModel.extraNotchPadSize.width / 2
                        )
                        .transition(
                            .offset(
                                x: -notchViewModel.extraNotchPadSize.width / 2
                            )
                            .combined(
                                with: .opacity
                            )
                        )
                    }
                }
            }
            
            if defaultsManager.hudStyle == .Progress {
                ProgressHUDView(
                    notchViewModel: notchViewModel
                )
            } else if defaultsManager.hudStyle == .Notched {
                NotchedHUDView(
                    notchViewModel: notchViewModel
                )
            }
        }
        .background {
            Color.black
        }
        .mask {
            NotchShape()
        }
        .scaleEffect(
            isHovered ? 1.05 : 1.0,
            anchor: .top
        )
        .shadow(
            radius: isHovered ? 5 : 0
        )
        .onHover { hovering in
            print("CollapsedNotchView hover: \(hovering)")
        }
        .onReceive(
            defaultsManager.objectWillChange
        ) {
            notchViewModel.hudRefreshTimer?.invalidate()
            notchViewModel.hudTimer?.invalidate()
            
            notchViewModel.hudIcon = nil
            notchViewModel.hudValue = nil
            
            if defaultsManager.hudEnabled {
                OSDUIManager.shared.stop()
            } else {
                OSDUIManager.shared.start()
            }
            
            notchViewModel.refreshNotchSize()
        }
        .onAppear {
            if defaultsManager.hudEnabled {
                OSDUIManager.shared.stop()
            } else {
                OSDUIManager.shared.start()
            }
            
            // Ensure clipboard monitoring is active
            ClipboardManager.shared.startMonitoring()
        }
    }
}

#Preview {
    CollapsedNotchView()
}
