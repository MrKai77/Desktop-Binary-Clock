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
            Button("Toggle Visibility") {
                NotificationCenter.default.post(name: Notification.Name.toggleVisibility, object: nil)
            }
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    
    // Define the window's controller
    private var windowController: NSWindowController?
    
    var isShown = true
    
    let windowPadding:CGFloat = 10
    let BinaryClockWindowWidth:CGFloat = 247
    let BinaryClockWindowHeight:CGFloat = 168
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        showWindow()
    }
    
    func showWindow() {
        // Get screen dimensions
        guard let screen = NSScreen.main else { return }
        let screenWidth = Int(screen.visibleFrame.width)
        let screenHeight = Int(screen.visibleFrame.height)
        
        if windowController != nil { return } else {
            // Define the window
            let window = NSWindow(contentRect: .zero,
                                  styleMask: .borderless,
                                  backing: .buffered,
                                  defer: true,
                                  screen: NSApp.keyWindow?.screen)
            
            window.collectionBehavior = .canJoinAllSpaces   // Makes window appear in all spaces
            window.isMovableByWindowBackground = false      // Makes window unmoveable by user
            window.backgroundColor = .clear                 // Makes window transparent (window is made in SwiftUI)
            window.level = .statusBar // Make window stay below all other windows
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
            window.makeKeyAndOrderInFrontOfSpaces()
        }
    }
    
    func hideWindow() {
        guard let windowController = windowController else { return } // If there's no open window, return
        
        windowController.close()       // Close window
        self.windowController = nil    // Release window controller (will need to be re-made to show window again)
    }
}

// Define some types for the next function (which uses Apple's private APIs)
private typealias CGSConnectionID = UInt
private typealias CGSSpaceID = UInt64
@_silgen_name("CGSCopySpaces")
private func CGSCopySpaces(_: Int, _: Int) -> CFArray
@_silgen_name("CGSAddWindowsToSpaces")
private func CGSAddWindowsToSpaces(_ cid: CGSConnectionID, _ windows: NSArray, _ spaces: NSArray)

// This extension allows the window to be put on "top" of spaces, making it slide with you when you change spaces!
extension NSWindow {
    func makeKeyAndOrderInFrontOfSpaces() {
        self.orderFrontRegardless()
        let contextID = NSApp.value(forKey: "contextID") as! Int
        let spaces: CFArray
        if #available(macOS 12.2, *) {
            spaces = CGSCopySpaces(contextID, 11)
        } else {
            spaces = CGSCopySpaces(contextID, 13)
        }
        // macOS 12.1 -> 13
        // macOS 12.2 beta 2 -> 9 or 11
        
        let windows = [NSNumber(value: windowNumber)]
        
        CGSAddWindowsToSpaces(CGSConnectionID(contextID), windows as CFArray, spaces)
    }
}

extension Notification.Name {
    static let toggleVisibility = Notification.Name("toggleVisibility")
}

extension View {
    func onReceive(
        _ name: Notification.Name,
        center: NotificationCenter = .default,
        object: AnyObject? = nil,
        perform action: @escaping (Notification) -> Void
    ) -> some View {
        onReceive(
            center.publisher(for: name, object: object),
            perform: action
        )
    }
}
