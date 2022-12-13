//
//  ContentView.swift
//  Binary Clock
//
//  Created by Kai Azim on 2022-12-13.
//

import SwiftUI

struct ContentView: View {
    
    let windowPadding = 10
    let windowWidth = 250
    let windowHeight = 175
    
    let refreshTime = Timer.publish(every: 1, tolerance: 0.5, on: .main, in: .common).autoconnect()
    @State var currentSecondDigit1:Int = 0
    @State var currentSecondDigit2:Int = 0
    @State var currentMinuteDigit1:Int = 0
    @State var currentMinuteDigit2:Int = 0
    @State var currentHourDigit1:Int = 0
    @State var currentHourDigit2:Int = 0
    
    @State var shouldShowSettings:Bool = false
    
    @State var colors = [Color(hex: "#f5e0dc"),
                         Color(hex: "#f2cdcd"),
                         Color(hex: "#f5c2e7"),
                         Color(hex: "#cba6f7"),
                         Color(hex: "#f38ba8"),
                         Color(hex: "#eba0ac"),
                         Color(hex: "#fab387"),
                         Color(hex: "#f9e2af"),
                         Color(hex: "#a6e3a1"),
                         Color(hex: "#94e2d5"),
                         Color(hex: "#89dceb"),
                         Color(hex: "#74c7ec"),
                         Color(hex: "#89b4fa"),
                         Color(hex: "#b4befe"),
                         Color(hex: "#cdd6f4")]
    @State var currentColor:Int = 0
    
    var body: some View {
        ZStack {
            Rectangle()
                .background(VisualEffectView())
                .foregroundColor(colors[currentColor].opacity(0.25))
            HStack {
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
                .fontDesign(.monospaced)
                .fontWeight(.semibold)
                .foregroundColor(colors[currentColor])
                .opacity(0.5)
                HStack {
                    digitCircles(currentHourDigit1, on: colors[currentColor].opacity(0.75), off: .clear)
                    digitCircles(currentHourDigit2, on: colors[currentColor].opacity(0.75), off: .clear)
                    
                    digitCircles(currentMinuteDigit1, on: colors[currentColor].opacity(0.75), off: .clear)
                    digitCircles(currentMinuteDigit2, on: colors[currentColor].opacity(0.75), off: .clear)
                    
                    digitCircles(currentSecondDigit1, on: colors[currentColor].opacity(0.75), off: .clear)
                    digitCircles(currentSecondDigit2, on: colors[currentColor].opacity(0.75), off: .clear)
                }
            }
        }
        .ignoresSafeArea()
        .animation(.easeOut(duration: 0.25), value: [currentSecondDigit1, currentSecondDigit2,
                                                    currentMinuteDigit1, currentMinuteDigit2,
                                                    currentHourDigit1, currentHourDigit2,
                                                    currentColor])
        .onReceive(refreshTime) { time in
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
            if currentColor >= colors.count-1 {
                currentColor = 0
            } else {
                currentColor += 1
            }
        }
    }
}

struct digitCircles: View {
    
    var columnDigit:Int
    
    var onColor:Color
    var offColor:Color
    
    init(_ digit:Int, on:Color, off:Color) {
        self.columnDigit = digit
        
        self.onColor = on
        self.offColor = off
    }
    
    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(onColor.opacity(0.2), lineWidth: 2.5)
                .frame(width: 27.5, height: 27.5)
                .background(RoundedRectangle(cornerRadius: 8).foregroundColor(pad(columnDigit, row: 0) ? onColor : offColor))
                .padding([.bottom], 1.25)
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(onColor.opacity(0.2), lineWidth: 2.5)
                .frame(width: 27.5, height: 27.5)
                .background(RoundedRectangle(cornerRadius: 8).foregroundColor(pad(columnDigit, row: 1) ? onColor : offColor))
                .padding([.bottom, .top], 1.25)
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(onColor.opacity(0.2), lineWidth: 2.5)
                .frame(width: 27.5, height: 27.5)
                .background(RoundedRectangle(cornerRadius: 8).foregroundColor(pad(columnDigit, row: 2) ? onColor : offColor))
                .padding([.bottom, .top], 1.25)
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(onColor.opacity(0.2), lineWidth: 2.5)
                .frame(width: 27.5, height: 27.5)
                .background(RoundedRectangle(cornerRadius: 8).foregroundColor(pad(columnDigit, row: 3) ? onColor : offColor))
                .padding([.top], 1.25)
        }
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
