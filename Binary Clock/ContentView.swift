//
//  ContentView.swift
//  Binary Clock
//
//  Created by Kai Azim on 2022-12-13.
//

import SwiftUI

struct ContentView: View {
    
    @NSApplicationDelegateAdaptor private var appDelegate: AppDelegate
    
    @State private var refreshTimer = Timer.publish(every: 1, tolerance: 0.5, on: .main, in: .common).autoconnect()
    @State private var currentSecondDigit1:Int = 0
    @State private var currentSecondDigit2:Int = 0
    @State private var currentMinuteDigit1:Int = 0
    @State private var currentMinuteDigit2:Int = 0
    @State private var currentHourDigit1:Int = 0
    @State private var currentHourDigit2:Int = 0
    
    @State private var isHovering:Bool = false

    // Currently uses Tokyo Night colors!
    @AppStorage("current_color", store: .standard) private var currentColor:Int = 0
    @State private var colorSelectionMode:Bool = false
    private let colors = [Color("Background 1"),
                          Color("Background 2"),
                          Color("Background 3"),
                          Color("Background 4"),
                          Color("Background 5"),
                          Color("Background 6"),
                          Color("Background 7"),
                          Color("Background 8"),
                          Color("Background 9"),
                          Color("Background 10"),
                          Color("Background 11"),
                          Color("Background 12"),
                          Color("Background 13"),
                          Color("Background 14"),
                          Color("Background 15")]
    
    var body: some View {
        ZStack {    // BINARY CLOCK
            Rectangle()
                .background(VisualEffectView())
                .foregroundColor(Color("Background").opacity(0.8))
                .cornerRadius(21)
            HStack {    // MAIN BINARY CLOCK VIEW
                Spacer()
                
                VStack {
                        Spacer()
                        Text("8")
                        Spacer()
                        Text("4")
                        Spacer()
                        Text("2")
                        Spacer()
                        Text("1")
                        Spacer()
                }
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundColor(colors[currentColor].opacity(0.75))
                
                Spacer()
                
                HStack {
                    digitCircles(currentHourDigit1, on: colors[currentColor].opacity(0.8), off: .clear, colorSelectionMode: colorSelectionMode)
                    digitCircles(currentHourDigit2, on: colors[currentColor].opacity(0.8), off: .clear, colorSelectionMode: colorSelectionMode)
                    
                    digitCircles(currentMinuteDigit1, on: colors[currentColor].opacity(0.8), off: .clear, colorSelectionMode: colorSelectionMode)
                    digitCircles(currentMinuteDigit2, on: colors[currentColor].opacity(0.8), off: .clear, colorSelectionMode: colorSelectionMode)
                    
                    digitCircles(currentSecondDigit1, on: colors[currentColor].opacity(0.8), off: .clear, colorSelectionMode: colorSelectionMode)
                    digitCircles(currentSecondDigit2, on: colors[currentColor].opacity(0.8), off: .clear, colorSelectionMode: colorSelectionMode)
                }
                
                Spacer()
            }
        }
        .ignoresSafeArea()
        .animation(.easeOut(duration: 0.2), value: [currentSecondDigit1, currentSecondDigit2,
                                                    currentMinuteDigit1, currentMinuteDigit2,
                                                    currentHourDigit1, currentHourDigit2,
                                                    currentColor])
        .animation(.easeOut(duration: 0.2), value: colorSelectionMode)
        .onReceive(refreshTimer) { time in
            let currentTime = Date()

            let timeFormatterSecond = DateFormatter()
            timeFormatterSecond.dateFormat = "ss"
            currentSecondDigit1 = Int(timeFormatterSecond.string(from: currentTime)[0]) ?? 0
            currentSecondDigit2 = Int(timeFormatterSecond.string(from: currentTime)[1]) ?? 0

            let timeFormatterMinute = DateFormatter()
            timeFormatterMinute.dateFormat = "mm"
            currentMinuteDigit1 = Int(timeFormatterMinute.string(from: currentTime)[0]) ?? 0
            currentMinuteDigit2 = Int(timeFormatterMinute.string(from: currentTime)[1]) ?? 0

            let timeFormatterHour = DateFormatter()
            timeFormatterHour.dateFormat = "hh"
            currentHourDigit1 = Int(timeFormatterHour.string(from: currentTime)[0]) ?? 0
            currentHourDigit2 = Int(timeFormatterHour.string(from: currentTime)[1]) ?? 0

            // CHANGE COLOR
            if colorSelectionMode == true {
                if currentColor >= colors.count-1 {
                    currentColor = 0
                } else {
                    currentColor += 1
                }
            }
        }
        .onTapGesture {
            colorSelectionMode.toggle()
        }
    }
}

struct digitCircles: View {
    
    private var columnDigit:Int
    
    private var onColor:Color
    private var offColor:Color
    
    private var strokeOpacity:Double = 0.2
    private var strokeWidth:Double = 2.5
    
    init(_ digit:Int, on:Color, off:Color, colorSelectionMode:Bool) {
        self.columnDigit = digit
        
        self.onColor = on
        self.offColor = off
        
        self.strokeOpacity = colorSelectionMode ? 0.25 : 0.2
        self.strokeWidth = colorSelectionMode ? 4 : 3
    }
    
    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(onColor.opacity(strokeOpacity), lineWidth: strokeWidth)
                .frame(width: 27.5, height: 27.5)
                .background(RoundedRectangle(cornerRadius: 8).foregroundColor(pad(columnDigit, row: 0) ? onColor : offColor))
                .padding([.bottom], 1.3)
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(onColor.opacity(strokeOpacity), lineWidth: strokeWidth)
                .frame(width: 27.5, height: 27.5)
                .background(RoundedRectangle(cornerRadius: 8).foregroundColor(pad(columnDigit, row: 1) ? onColor : offColor))
                .padding([.bottom, .top], 1.3)
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(onColor.opacity(strokeOpacity), lineWidth: strokeWidth)
                .frame(width: 27.5, height: 27.5)
                .background(RoundedRectangle(cornerRadius: 8).foregroundColor(pad(columnDigit, row: 2) ? onColor : offColor))
                .padding([.bottom, .top], 1.3)
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(onColor.opacity(strokeOpacity), lineWidth: strokeWidth)
                .frame(width: 27.5, height: 27.5)
                .background(RoundedRectangle(cornerRadius: 8).foregroundColor(pad(columnDigit, row: 3) ? onColor : offColor))
                .padding([.top], 1.3)
        }
    }
    
    // Adapted from https://stackoverflow.com/questions/26181221/how-to-convert-a-decimal-number-to-binary-in-swift
    func pad(_ input: Int, row:Int) -> Bool {
        let inputStr = String(input, radix: 2)
        var padded = inputStr
        for _ in 0..<(4 - inputStr.count) {
            padded = "0" + padded
        }
        let output = padded[row] == "1" ? true : false
        return output
    }
}

// A view for a very translucent material
struct VisualEffectView: NSViewRepresentable {
    func makeNSView(context: Context) -> NSVisualEffectView {
        let effectView = NSVisualEffectView()
        effectView.state = .active
        effectView.material = .hudWindow
        effectView.isEmphasized = true
        effectView.blendingMode = .behindWindow
        return effectView
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
    }
}

extension String {
    subscript(idx: Int) -> String {
        String(self[index(startIndex, offsetBy: idx)])
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
