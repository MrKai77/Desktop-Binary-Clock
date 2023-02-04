//
//  Extensions.swift
//  Binary Clock
//
//  Created by Kai Azim on 2023-02-04.
//

import SwiftUI

extension String {
    subscript(idx: Int) -> String {
        String(self[index(startIndex, offsetBy: idx)])
    }
}

// SwiftUI view for NSVisualEffect
struct VisualEffectView: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode
    
    func makeNSView(context: Context) -> NSVisualEffectView {
        let visualEffectView = NSVisualEffectView()
        visualEffectView.material = material
        visualEffectView.blendingMode = blendingMode
        visualEffectView.state = NSVisualEffectView.State.active
        visualEffectView.isEmphasized = true
        return visualEffectView
    }

    func updateNSView(_ visualEffectView: NSVisualEffectView, context: Context) {
        visualEffectView.material = material
        visualEffectView.blendingMode = blendingMode
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
