//
//  AppleScriptRunner.swift
//  AppleScriptTest
//
//  Created by Mark Alldritt on 2021-02-02.
//
//  From https://github.com/alldritt/SwiftUIAppleScript

import SwiftUI
import Cocoa


class AppleScriptRunner: ObservableObject, Hashable {
    class Error: Equatable {
        //  Conform to Equatable
        static func == (lhs: AppleScriptRunner.Error, rhs: AppleScriptRunner.Error) -> Bool {
            return lhs.errorDict == rhs.errorDict
        }
        
        private let errorDict: NSDictionary
        
        var number: OSStatus {
            return (errorDict[NSAppleScript.errorNumber] as? NSNumber)?.int32Value ?? noErr
        }
        var message: String {
            return errorDict[NSAppleScript.errorMessage] as? String ?? briefMessage
        }
        var briefMessage: String {
            return errorDict[NSAppleScript.errorBriefMessage] as? String ?? "unknown error"
        }
        var range: NSRange? {
            return (errorDict[NSAppleScript.errorBriefMessage] as? NSValue)?.rangeValue
        }
        var application: String? {
            return errorDict[NSAppleScript.errorAppName] as? String
        }

        init(_ errorDict: NSDictionary) {
            self.errorDict = errorDict
        }
    }
    
    enum State: Equatable {
        case idle, running, complete(NSAppleEventDescriptor), error(Error)
    }
    
    //  Conform to Equitable
    static func == (lhs: AppleScriptRunner, rhs: AppleScriptRunner) -> Bool {
        return lhs.id == rhs.id
    }
    
    //  Conform to Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    let id = UUID()
    private let script: NSAppleScript

    @Published private (set) var state = State.idle

    init(_ source: String) {
        if let script = NSAppleScript(source: source) {
            self.script = script
        }
        else {
            fatalError("Cannot compile source")
        }
    }
        
    private func start() {
        state = .running
    }
    
    private func completed(_ resultDesc: NSAppleEventDescriptor, error: NSDictionary?) {
        if let error = error  {
            print("error: \(error)")
            self.state = .error(Error(error))
        }
        else {
//            print("result: \(resultDesc)")
            self.state = .complete(resultDesc)
            
        }
    }
    
    public func executeSync() {
        start()
        
        var error: NSDictionary? = nil
        let resultDesc = self.script.executeAndReturnError(&error)

        completed(resultDesc, error: error)
    }
    
    public func executeAsync() {
        start()
        DispatchQueue.global(qos: .background).async {
            var error: NSDictionary? = nil
            let resultDesc = self.script.executeAndReturnError(&error)
            
            DispatchQueue.main.async {
                self.completed(resultDesc, error: error)
            }
        }
    }

}

extension NSAppleEventDescriptor {
    var display: String {
        //  A quick and dirty means of converting an descriptor to string
        switch self.descriptorType {
        case typeSInt16,
             typeUInt16,
             typeSInt32,
             typeUInt32:
            return "\(self.int32Value)"

        case typeBoolean:
            return self.booleanValue ? "true" : "false"

        case typeLongDateTime:
            return "\(self.dateValue!)"
            
        case typeAEText,
             typeIntlText,
             typeUnicodeText:
            return self.stringValue!

        case OSType(1954115685):
            return "<missing value>"
            
        case typeAEList:
            var items = [String]()
            
            for i in 1...self.numberOfItems {
                items.append(self.atIndex(i)!.display)
            }
            return "[" + items.joined(separator: ", ") + "]"
        
        default:
            return "\(self)"
        }
    }
}
