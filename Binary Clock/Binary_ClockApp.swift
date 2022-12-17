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
    
    var screenWidth:Int = 0
    var screenHeight:Int = 0
    
    let windowPadding:CGFloat = 10
    
    let BinaryClockWindowWidth:CGFloat = 251
    let BinaryClockWindowHeight:CGFloat = 168
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        showWindow()
    }
    
    func showWindow() {
        // Get screen dimensions
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
            
            window.collectionBehavior = .canJoinAllSpaces   // Makes window appear in all spaces
            window.isMovableByWindowBackground = false      // Makes window unmoveable by user
            window.backgroundColor = .clear                 // Makes window transparent (window is made in SwiftUI)
            window.level = NSWindow.Level(rawValue: NSWindow.Level.normal.rawValue - 1) // Make window stay below all other windows
            window.setFrame(NSRect(x: 0,
                                   y: 0,
                                   width: screenWidth,
                                   height: screenHeight),
                            display: false,
                            animate: true)  // Make the window as big as the readable part on the screen
            
            
            // Assign the SwiftUI ContentView to imageWindow
            window.contentView = NSHostingView(rootView: BinaryClockView())
            
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
