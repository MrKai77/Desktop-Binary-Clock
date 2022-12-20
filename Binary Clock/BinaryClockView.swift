//
//  BinaryClockView.swift
//  Binary Clock
//
//  Created by Kai Azim on 2022-12-13.
//

import SwiftUI

struct BinaryClockView: View {
    
    @NSApplicationDelegateAdaptor private var appDelegate: AppDelegate
    
    // Variables to store the time
    @State private var refreshTimer = Timer.publish(every: 1, tolerance: 0.5, on: .main, in: .common).autoconnect()
    @State private var currentSecondDigit1:Int = 0
    @State private var currentSecondDigit2:Int = 0
    @State private var currentMinuteDigit1:Int = 0
    @State private var currentMinuteDigit2:Int = 0
    @State private var currentHourDigit1:Int = 0
    @State private var currentHourDigit2:Int = 0

    // The color information (Currently uses Tokyo Night colors!)
    @AppStorage("current_color", store: .standard) private var currentColor:Int = 0
    @State private var colorSelectionMode:Bool = false
    @State private var colors = [Color("Text"),
                                 Color("Rosewater"),
                                 Color("Flamingo"),
                                 Color("Pink"),
                                 Color("Mauve"),
                                 Color("Red"),
                                 Color("Maroon"),
                                 Color("Peach"),
                                 Color("Yellow"),
                                 Color("Green"),
                                 Color("Teal"),
                                 Color("Sky"),
                                 Color("Sapphire"),
                                 Color("Blue"),
                                 Color("Lavender")]
    
    var body: some View {
        HStack {
            Spacer()
            VStack {
                
                Spacer()
                
                ZStack {    // BINARY CLOCK
                    Rectangle() // The background
                        .foregroundColor(Color("Background"))
                        .cornerRadius(21)
                        .shadow(radius: 2)
                    HStack {
                        Spacer()
                        
                        VStack {    // Guides for reading the binary clock
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
                        .foregroundColor(colors[currentColor].opacity(0.8))
                        
                        Spacer()
                        
                        HStack {    // These are the 6 rows of on/off for the binary clock
                            BinaryClockDigits(currentHourDigit1, on: colors[currentColor].opacity(0.8), off: .clear, colorSelectionMode: colorSelectionMode)
                            BinaryClockDigits(currentHourDigit2, on: colors[currentColor].opacity(0.8), off: .clear, colorSelectionMode: colorSelectionMode)
                            
                            BinaryClockDigits(currentMinuteDigit1, on: colors[currentColor].opacity(0.8), off: .clear, colorSelectionMode: colorSelectionMode)
                            BinaryClockDigits(currentMinuteDigit2, on: colors[currentColor].opacity(0.8), off: .clear, colorSelectionMode: colorSelectionMode)
                            
                            BinaryClockDigits(currentSecondDigit1, on: colors[currentColor].opacity(0.8), off: .clear, colorSelectionMode: colorSelectionMode)
                            BinaryClockDigits(currentSecondDigit2, on: colors[currentColor].opacity(0.8), off: .clear, colorSelectionMode: colorSelectionMode)
                        }
                        
                        Spacer()
                    }
                }
                .animation(.easeOut(duration: 0.2), value: [currentSecondDigit1, currentSecondDigit2,
                                                            currentMinuteDigit1, currentMinuteDigit2,
                                                            currentHourDigit1, currentHourDigit2,
                                                            currentColor])
                .animation(.easeOut(duration: 0.2), value: colorSelectionMode)
                .onReceive(refreshTimer) { time in
                    // REFRESH TIME
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
                .frame(width: appDelegate.BinaryClockWindowWidth, height: appDelegate.BinaryClockWindowHeight)
                .padding(appDelegate.windowPadding)
            }
        }
    }
}

struct BinaryClockDigits: View {
    
    private var columnDigit:Int
    
    private var onColor:Color
    private var offColor:Color
    
    private var strokeOpacity:Double = 0.2
    private var strokeWidth:Double = 2.5
    
    private var pad0:Bool = false
    private var pad1:Bool = false
    private var pad2:Bool = false
    private var pad3:Bool = false
    
    init(_ digit:Int, on:Color, off:Color, colorSelectionMode:Bool) {
        self.columnDigit = digit
        
        self.onColor = on
        self.offColor = off
        
        self.strokeOpacity = colorSelectionMode ? 0.3 : 0.2
        self.strokeWidth = colorSelectionMode ? 4 : 3
        
        self.pad0 = pad(columnDigit, row: 0)
        self.pad1 = pad(columnDigit, row: 1)
        self.pad2 = pad(columnDigit, row: 2)
        self.pad3 = pad(columnDigit, row: 3)
    }
    
    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(onColor.opacity(pad0 ? 0 : strokeOpacity), lineWidth: strokeWidth)
                .frame(width: 27.5, height: 27.5)
                .background(RoundedRectangle(cornerRadius: 8).foregroundColor(pad0 ? onColor : offColor))
                .padding([.bottom], 1.3)
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(onColor.opacity(pad1 ? 0 : strokeOpacity), lineWidth: strokeWidth)
                .frame(width: 27.5, height: 27.5)
                .background(RoundedRectangle(cornerRadius: 8).foregroundColor(pad1 ? onColor : offColor))
                .padding([.bottom, .top], 1.3)
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(onColor.opacity(pad2 ? 0 : strokeOpacity), lineWidth: strokeWidth)
                .frame(width: 27.5, height: 27.5)
                .background(RoundedRectangle(cornerRadius: 8).foregroundColor(pad2 ? onColor : offColor))
                .padding([.bottom, .top], 1.3)
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(onColor.opacity(pad3 ? 0 : strokeOpacity), lineWidth: strokeWidth)
                .frame(width: 27.5, height: 27.5)
                .background(RoundedRectangle(cornerRadius: 8).foregroundColor(pad3 ? onColor : offColor))
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

extension String {
    subscript(idx: Int) -> String {
        String(self[index(startIndex, offsetBy: idx)])
    }
}
