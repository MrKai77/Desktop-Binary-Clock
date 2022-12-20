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
    var binaryClockWindowController: NSWindowController?
    var menubarWindowController: NSWindowController?
    
    var screenWidth:Int = 0
    var screenHeight:Int = 0
    
    var realScreenHeight:Int = 0
    var menubarHeight:Int = 0
    
    var activeAppName = ""
    
    let windowPadding:CGFloat = 10
    
    let BinaryClockWindowWidth:CGFloat = 251
    let BinaryClockWindowHeight:CGFloat = 168
    
    override init() {
        // Get screen dimensions
        if let screen = NSScreen.main {
            screenHeight = Int(screen.visibleFrame.height)
            realScreenHeight = Int(screen.frame.height)
            
            menubarHeight = realScreenHeight - screenHeight
        }
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        checkAccessibilityAccess()
        
        showBinaryClock()
        showMenubarWindow()
        
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name(rawValue: "NSApplicationDidChangeScreenParametersNotification"),
            object: NSApplication.shared,
            queue: .main) { notification in
                self.positionMenubarWindow()
            }
    }
    
    func showMenubarWindow() {
        if let windowController = menubarWindowController {
            windowController.window?.orderFrontRegardless()    // If window is already shown, focus it
        } else {
            let panel = NSPanel(contentRect: .zero,
                                styleMask: [.borderless, .nonactivatingPanel],
                                backing: .buffered,
                                defer: true,
                                screen: NSApp.keyWindow?.screen)
            panel.hasShadow = false
            panel.becomesKeyOnlyIfNeeded = true
            panel.collectionBehavior = .canJoinAllSpaces
            panel.level = .screenSaver
            panel.backgroundColor = .clear
            panel.contentView = NSHostingView(rootView: MenubarView())
            panel.orderFrontRegardless()

            menubarWindowController = .init(window: panel)
            positionMenubarWindow()
        }
    }
    
    func positionMenubarWindow() {
        guard let windowController = menubarWindowController else { return } // If there's no open panel, return
        
        if let screen = NSScreen.main {
            screenWidth = Int(screen.visibleFrame.width)
            screenHeight = Int(screen.visibleFrame.height)
        }
        
        windowController.window?.setFrame(NSRect(x: 0, y: screenHeight, width: screenWidth, height: menubarHeight), display: true)
    }
    
    func closeMenubarWindow() {
        guard let windowController = menubarWindowController else { return } // If there's no open window, return
        
        windowController.close()                // Close window
        self.binaryClockWindowController = nil  // Release window controller (will need to be re-made to show window again)
    }
    
    func showBinaryClock() {
        if let windowController = binaryClockWindowController {
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
            window.contentView = NSHostingView(rootView: BinaryClockView()) // Assign the SwiftUI ContentView to window
            window.orderFrontRegardless()
            
            binaryClockWindowController = .init(window: window)
            positionBinaryClock()
        }
    }
    
    func positionBinaryClock() {
        guard let windowController = binaryClockWindowController else { return } // If there's no open window, return
        
        if let screen = NSScreen.main {
            screenWidth = Int(screen.visibleFrame.width)
            screenHeight = Int(screen.visibleFrame.height)
        }
        
        windowController.window?.setFrame(NSRect(x: 0, y: 0, width: screenWidth, height: screenHeight), display: false)
    }
    
    func closeBinaryClock() {
        guard let windowController = binaryClockWindowController else { return } // If there's no open window, return
        
        windowController.close()                // Close window
        self.binaryClockWindowController = nil  // Release window controller (will need to be re-made to show window again)
    }
    
    func checkAccessibilityAccess(){
        //get the value for accessibility
        let checkOptPrompt = kAXTrustedCheckOptionPrompt.takeUnretainedValue() as NSString
        let options = [checkOptPrompt: true]
        
        //translate into boolean value
        let accessEnabled = AXIsProcessTrustedWithOptions(options as CFDictionary?)
        
        if !accessEnabled {
            print("Prompted user for accessibility access!")
        }
    }
}
