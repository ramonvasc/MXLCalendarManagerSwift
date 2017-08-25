//
//  MXLCalendarManager.swift
//  Pods
//
//  Created by Ramon Vasconcelos on 25/08/2017.
//
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import Foundation

#if os(iOS)
    import UIKit
#endif

class MXLCalendarManager {

    func scanICSFileAtRemoteURL(fileURL: URL, withCompletionHandler callback: @escaping (MXLCalendar?, Error?) -> Void) {
        #if os(iOS)
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        #endif

        var fileData = Data()
        DispatchQueue.global(qos: .default).async {
            do {
                fileData = try Data(contentsOf: fileURL)
            } catch (let downloadError) {
                #if os(iOS)
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                #endif
                callback(nil, downloadError)
                return
            }

            DispatchQueue.main.async {
                #if os(iOS)
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                #endif
                guard let fileString = String(data: fileData, encoding: .utf8) else {
                    return
                }
                self.parse(icsString: fileString, withCompletionHandler: callback)
            }
        }
    }

    func scanICSFileatLocalPath(filePath: String, withCompletionHandler callback: @escaping (MXLCalendar?, Error?) -> Void) {
        var calendarFile = String()
        do {
            calendarFile = try String(contentsOfFile: filePath, encoding: .utf8)
        } catch (let fileError) {
            callback(nil, fileError)
            return
        }

        parse(icsString: calendarFile, withCompletionHandler: callback)
    }

    func createAttendee(string: String) -> MXLCalendarAttendee? {
        var eventScanner = Scanner(string: string)
        var uri = String()
        var role = String()
        var comomName = String()
        var uriPointer: NSString?
        var attributesPointer: NSString?
        var holderPointer: NSString?

        eventScanner.scanUpTo(":", into: &attributesPointer)
        eventScanner.scanUpTo("\n", into: &uriPointer)
        if let uriPointer = uriPointer {
            uri = (uriPointer.substring(from: 1))
        }

        if let attributesPointer = attributesPointer {
            eventScanner = Scanner(string: attributesPointer as String)

            eventScanner.scanUpTo("ROLE", into: nil)
            eventScanner.scanUpTo(";", into: &holderPointer)

            if let holderPointer = holderPointer {
                role = holderPointer.replacingOccurrences(of: "ROLE", with: "")
            }

            eventScanner = Scanner(string: attributesPointer as String)
            eventScanner.scanUpTo("CN", into: nil)
            eventScanner.scanUpTo(";", into: &holderPointer)

            if let holderPointer = holderPointer {
                comomName = holderPointer.replacingOccurrences(of: "CN", with: "")
            }
        }
        guard let roleEnum = Role(rawValue: role) else {
            return nil
        }
        return MXLCalendarAttendee(withRole: roleEnum, commonName: comomName, andUri: uri)
    }
    
    func parse(icsString: String, withCompletionHandler callback: @escaping (MXLCalendar?, Error?) -> Void) {
        
    }
}
