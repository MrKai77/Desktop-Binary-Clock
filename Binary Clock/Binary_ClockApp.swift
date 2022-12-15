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
        MenuBarExtra("Binary Clock", systemImage: "clock.circle.fill") {
            Text("Binary Clock")
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    
    // Define the window's controller
    private var windowController: NSWindowController?
    
    private var screenWidth:Int = 0
    private var screenHeight:Int = 0
    
    private let windowPadding:Int = 10
    private let windowWidth:Int = 251
    private let windowHeight:Int = 168
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        showWindow()
    }
    
    func showWindow() {
        if let screen = NSScreen.main {
            screenWidth = Int(screen.visibleFrame.width)
            screenHeight = Int(screen.visibleFrame.height)
        }
        
        if let windowController = windowController {
            windowController.window?.orderFrontRegardless()    // If window is already shown, focus it
        } else {
            // Define the window
            let window = NSWindow(contentRect: .zero,
                                  styleMask: .borderless,
                                  backing: .buffered,
                                  defer: true,
                                  screen: NSApp.keyWindow?.screen)
            
            // The following is self-explanatory
            window.isMovableByWindowBackground = false
            window.backgroundColor = .clear
            window.hasShadow = true
            window.level = NSWindow.Level(rawValue: NSWindow.Level.normal.rawValue - 1)
            window.setFrame(NSRect(x: screenWidth-windowWidth-windowPadding,
                                   y: windowPadding,
                                   width: windowWidth,
                                   height: windowHeight),
                            display: false,
                            animate: true)
            
            
            
            // Assign the SwiftUI ContentView to imageWindow
            window.contentView = NSHostingView(rootView: ContentView())
            
            // Assign imageWindow to imageWindowController (NSWindowController)
            windowController = .init(window: window)
            
            // Show window
            window.orderFrontRegardless()
        }
    }
    
    func hideWindow() {
        guard let windowController = windowController else { return } // If there's no open window, return
        
        windowController.close()       // Close window
        self.windowController = nil    // Release window controller (will need to be re-made to show window again)
    }
    
}
