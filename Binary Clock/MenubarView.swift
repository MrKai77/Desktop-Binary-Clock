//
//  MenubarView.swift
//  Binary Clock
//
//  Created by Kai Azim on 2022-12-18.
//

import SwiftUI

struct MenubarView: View {
    
    @NSApplicationDelegateAdaptor private var appDelegate: AppDelegate
    
    // Applescript to open Apple menu
    @ObservedObject var AS_showAppleMenu = AppleScriptRunner("""
    tell application "System Events"
        tell process "\(NSWorkspace.shared.frontmostApplication!.localizedName!)"
            click menu 1 of menu bar 1
        end tell
    end tell
    """)
    
    // Applescript to open Control Center
    @ObservedObject var AS_openControlCenter = AppleScriptRunner("""
    tell application "System Events"
        tell its application process "ControlCenter"
            tell its menu bar 1
                click its menu bar item 2
            end tell
        end tell
    end tell
    """)
    
    // Applescript to open Notification Center
    @ObservedObject var AS_openNotificationCenter = AppleScriptRunner("""
    tell application "System Events"
        tell its application process "ControlCenter"
            tell its menu bar 1
                click its menu bar item 1
            end tell
        end tell
    end tell
    """)
    
    // Applescript to read current unread mail
    @ObservedObject var AS_currentUnreadMail = AppleScriptRunner("""
    on run
      tell application "Mail"
        return the unread count of inbox
      end tell
    end run
    """)
    @State var currentUnreadMail = ""
    
    // Applescript to read current playing track in Apple Music
    @ObservedObject var AS_currentPlayingMusic = AppleScriptRunner("""
    tell application "Music"
        set songTitle to name of current track
        return songTitle
    end tell
    """)
    @State private var currentMusic = ""
    
    @State private var isMenubarShown = true
    
    @State private var refreshCommandsFrequent = Timer.publish(every: 2, tolerance: 1, on: .main, in: .common).autoconnect()
    @State private var refreshCommandsHourly = Timer.publish(every: 3600, tolerance: 300, on: .main, in: .common).autoconnect()
    @State private var whoami = ""
    @State private var currentDate = ""
    @State private var currentTime = ""
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(Color("Background"))
            
            HStack(spacing: 5) {
                Button(action: {        // SHOW APPLE MENU
                    appDelegate.checkAccessibilityAccess()
                    AS_showAppleMenu.executeAsync()
                }, label: {
                    Label(whoami, systemImage: "apple.logo")
                        .padding(5)
                        .background(Color("Lavender"))
                        .cornerRadius(5)
                })
                
                Button(action: {    // SHOW MENUBAR
                    isMenubarShown = false
                }, label: {
                    Label("Access Menubar", systemImage: "menubar.rectangle")
                        .padding(5)
                        .background(Color("Flamingo"))
                        .cornerRadius(5)
                })
                
                Group { // APP SHORTCUTS
                    Button(action: {
                        _ = shell("open -a Obsidian")
                    }, label: {
                        Label("Obsidian", systemImage: "list.clipboard.fill")
                            .padding(5)
                            .background(Color("Blue"))
                            .cornerRadius(5)
                    })
                    
                    Button(action: {
                        _ = shell("open -a Arc")
                    }, label: {
                        Label("Arc", systemImage: "safari.fill")
                            .padding(5)
                            .background(Color("Sky"))
                            .cornerRadius(5)
                    })
                    
                    Button(action: {
                        _ = shell("open -a iTerm")
                    }, label: {
                        Label("iTerm", systemImage: "terminal.fill")
                            .padding(5)
                            .background(Color("Peach"))
                            .cornerRadius(5)
                    })
                    
                    Button(action: {
                        _ = shell("open -a Visual\\ Studio\\ Code")
                    }, label: {
                        Label("VSCode", systemImage: "doc.text.fill")
                            .padding(5)
                            .background(Color("Rosewater"))
                            .cornerRadius(5)
                    })
                }
                
                Spacer()
                
                if currentUnreadMail != "0" {
                    Button(action: {
                        _ = shell("open -a Mail")
                    }, label: {
                        Label(currentUnreadMail, systemImage: "envelope.fill")
                            .padding(5)
                            .background(Color("Mauve"))
                            .cornerRadius(5)
                    })
                }
                
                if currentMusic != "" {
                    Button(action: {
                        _ = shell("open -a Music")
                    }, label: {
                        Label(currentMusic, systemImage: "music.note")
                            .padding(5)
                            .background(Color("Red"))
                            .cornerRadius(5)
                    })
                }
                
                Button(action: {        // OPEN CONTROL CENTER
                    AS_openControlCenter.executeAsync()
                }, label: {
                    Label(currentTime, systemImage: "clock.fill")
                        .padding(5)
                        .background(Color("Yellow"))
                        .cornerRadius(5)
                })
                
                Button(action: {        // OPEN NOTIFICATION CENTER
                    AS_openNotificationCenter.executeAsync()
                }, label: {
                    Label(currentDate, systemImage: "calendar")
                        .padding(5)
                        .background(Color("Sapphire"))
                        .cornerRadius(5)
                })
            }
            .padding(5)
            .buttonStyle(.plain)
            .foregroundColor(Color("Background"))
            .font(.system(size: 12, weight: .medium, design: .monospaced))
        }
        .offset(y: isMenubarShown ? 0 : CGFloat(-appDelegate.menubarHeight))
        .animation(.easeIn, value: isMenubarShown)
        .animation(.easeOut, value: [currentMusic, currentUnreadMail, currentDate, currentTime])
        .onReceive(refreshCommandsFrequent) { time in
            frequentCommandRefresh()
        }
        .onAppear(perform: {
            frequentCommandRefresh()
        })
    }
    
    func frequentCommandRefresh() {
        self.whoami = shell("whoami")
        self.currentDate = shell("date +\"%D\"")
        self.currentTime = shell("date +\"%I:%M %p\"")
            
        // These are synchronous since the next commands need them
        AS_currentUnreadMail.executeSync()
        AS_currentPlayingMusic.executeSync()
        
        switch AS_currentUnreadMail.state {
            case .running:
            break;
            
            case .complete(let result):
            currentUnreadMail = result.display

            case .error(let error):
            currentUnreadMail = ""
            print(error.message)
            
            case .idle:
            break;
        }
        
        switch AS_currentPlayingMusic.state {
            case .running:
            break;
            
            case .complete(let result):
            currentMusic = result.display

            case .error(let error):
            currentMusic = ""
            print(error.message)
            
            case .idle:
            break;
        }
        
        if currentMusic.count > 20 {    // If song title is longer than 20 characters
            currentMusic = String(currentMusic.prefix(20))
            if currentMusic.last == " " {   // If last character is a whitespace
                currentMusic = String(currentMusic.dropLast())
            }
            currentMusic += "…"
        }
        
        if isMenubarShown == false {
            let mouseYLocation = NSEvent.mouseLocation.y
            
            if appDelegate.screenHeight-Int(mouseYLocation) > appDelegate.menubarHeight {
                isMenubarShown = true
            }
        }
    }
    
    // https://stackoverflow.com/questions/26971240/how-do-i-run-a-terminal-command-in-a-swift-script-e-g-xcodebuild
    func shell(_ command: String) -> String {
        let task = Process()
        let pipe = Pipe()
        
        task.standardOutput = pipe
        task.standardError = pipe
        task.arguments = ["-c", command]
        task.launchPath = "/bin/zsh"
        task.standardInput = nil
        task.launch()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        var output = String(data: data, encoding: .utf8)!
        output = String(output.dropLast())  // Removes newline at end
        
        return output
    }
}
