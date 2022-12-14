//
//  Binary_ClockApp.swift
//  Binary Clock
//
//  Created by Kai Azim on 2022-12-13.
//

import SwiftUI

@main
struct Binary_ClockApp: App {
    
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowStyle(.hiddenTitleBar)
    }
}


class AppDelegate: NSObject, NSApplicationDelegate {
    
    private let windowPadding = 10
    private let windowWidth = 250
    private let windowHeight = 170
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // SET UP WINDOW
        for window in NSApplication.shared.windows {
            window.backgroundColor = .clear
            window.styleMask.remove(.resizable)
            window.isMovable = false
            window.canBecomeVisibleWithoutLogin = true
            window.level = NSWindow.Level(rawValue: NSWindow.Level.normal.rawValue - 1)
            window.standardWindowButton(.miniaturizeButton)?.isHidden = true
            window.standardWindowButton(.closeButton)?.isHidden = true
            window.standardWindowButton(.zoomButton)?.isHidden = true

            if let screen = NSScreen.main {
                window.setFrame(NSRect(x: Int(screen.frame.width)-windowWidth-windowPadding, y: 0+windowPadding, width: windowWidth, height: windowHeight), display: false, animate: true)
            }
        }
    }
}
