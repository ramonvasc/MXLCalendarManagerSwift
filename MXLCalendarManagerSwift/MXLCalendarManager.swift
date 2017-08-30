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
        var regex = NSRegularExpression()
        do {
            regex = try NSRegularExpression(pattern: "\n +", options: .caseInsensitive)
        } catch (let error) {
            print(error)
        }
        let range = NSRange(location: 0, length: (icsString as NSString).length)
        let icsStringWithoutNewLines = regex.stringByReplacingMatches(in: icsString, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: range, withTemplate: "")

        // Pull out each line from the calendar file
        var eventsArray = icsStringWithoutNewLines.components(separatedBy: "BEGIN:VEVENT")
        let calendar = MXLCalendar()
        var calendarStringPointer: NSString?
        var calendarString = String()

        // Remove the first item (that's just all the stuff before the first VEVENT)
        if eventsArray.count > 0 {
            let scanner = Scanner(string: eventsArray[0])
            scanner.scanUpTo("TZID:", into: nil)
            scanner.scanUpTo("\n", into: &calendarStringPointer)
            calendarString = String(calendarStringPointer ?? "")
            calendarString = calendarString.replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: "\r", with: "").replacingOccurrences(of: "TZID", with: "")

            eventsArray.remove(at: 0)
        }

        var eventScanner = Scanner()

        // For each event, extract the data
        for event in eventsArray {
            var timezoneIDStringPointer: NSString?
            var timezoneIDString = String()
            var startDateTimeStringPointer: NSString?
            var startDateTimeString = String()
            var endDateTimeStringPointer: NSString?
            var endDateTimeString = String()
            var eventUniqueIDStringPointer: NSString?
            var eventUniqueIDString = String()
            var recurrenceIDStringPointer: NSString?
            var recurrenceIDString = String()
            var createdDateTimeStringPointer: NSString?
            var createdDateTimeString = String()
            var descriptionStringPointer: NSString?
            var descriptionString = String()
            var lastModifiedDateTimeStringPointer: NSString?
            var lastModifiedDateTimeString = String()
            var locationStringPointer: NSString?
            var locationString = String()
            var sequenceStringPointer: NSString?
            var sequenceString = String()
            var statusStringPointer: NSString?
            var statusString = String()
            var summaryStringPointer: NSString?
            var summaryString = String()
            var transStringPointer: NSString?
            var transString = String()
            var timeStampStringPointer: NSString?
            var timeStampString = String()
            var repetitionStringPointer: NSString?
            var repetitionString = String()
            var exceptionRuleStringPointer: NSString?
            var exceptionRuleString = String()
            var exceptionDates = [String]()
            var attendees = [MXLCalendarAttendee]()

            // Extract event time zone ID
            eventScanner = Scanner(string: event)
            eventScanner.scanUpTo("DTSTART;TZID=", into: nil)
            eventScanner.scanUpTo(":", into: &timezoneIDStringPointer)
            timezoneIDString = String(timezoneIDStringPointer ?? "")
            timezoneIDString = timezoneIDString.replacingOccurrences(of: "DTSTART;TZID=", with: "").replacingOccurrences(of: "\n", with: "")

            if timezoneIDString == "" {
                // Extract event time zone ID
                eventScanner = Scanner(string: event)
                eventScanner.scanUpTo("TZID:", into: nil)
                eventScanner.scanUpTo("\n", into: &timezoneIDStringPointer)
                timezoneIDString = String(timezoneIDStringPointer ?? "")
                timezoneIDString = timezoneIDString.replacingOccurrences(of: "TZID:", with: "").replacingOccurrences(of: "\n", with: "")
            }

            // Extract start time
            eventScanner = Scanner(string: event)
            eventScanner.scanUpTo(String(format: "DTSTART;TZID=%@:", timezoneIDString), into: nil)
            eventScanner.scanUpTo("\n", into: &startDateTimeStringPointer)
            startDateTimeString = String(startDateTimeStringPointer ?? "")
            startDateTimeString = startDateTimeString.replacingOccurrences(of: String(format: "DTSTART;TZID=%@:", timezoneIDString), with: "").replacingOccurrences(of: "\r", with: "")

            if startDateTimeString == "" {
                eventScanner = Scanner(string: event)
                eventScanner.scanUpTo("DTSTART:", into: nil)
                eventScanner.scanUpTo("\n", into: &startDateTimeStringPointer)
                startDateTimeString = String(startDateTimeStringPointer ?? "")
                startDateTimeString = startDateTimeString.replacingOccurrences(of: "DTSTART:", with: "").replacingOccurrences(of: "\r", with: "")

                if startDateTimeString == "" {
                    eventScanner = Scanner(string: event)
                    eventScanner.scanUpTo("DTSTART;VALUE=DATE:", into: nil)
                    eventScanner.scanUpTo("\n", into: &startDateTimeStringPointer)
                    startDateTimeString = String(startDateTimeStringPointer ?? "")
                    startDateTimeString = startDateTimeString.replacingOccurrences(of: "DTSTART;VALUE=DATE:", with: "").replacingOccurrences(of: "\r", with: "")
                }
            }

            // Extract end time
            eventScanner = Scanner(string: event)
            eventScanner.scanUpTo(String(format: "DTEND;TZID=%@:", timezoneIDString), into: nil)
            eventScanner.scanUpTo("\n", into: &endDateTimeStringPointer)
            endDateTimeString = String(endDateTimeStringPointer ?? "")
            endDateTimeString = endDateTimeString.replacingOccurrences(of: String(format: "DTEND;TZID=%@:", timezoneIDString), with: "").replacingOccurrences(of: "\r", with: "")

            if startDateTimeString == "" {
                eventScanner = Scanner(string: event)
                eventScanner.scanUpTo("DTEND:", into: nil)
                eventScanner.scanUpTo("\n", into: &endDateTimeStringPointer)
                endDateTimeString = String(endDateTimeStringPointer ?? "")
                endDateTimeString = endDateTimeString.replacingOccurrences(of: "DTEND:", with: "").replacingOccurrences(of: "\r", with: "")

                if startDateTimeString == "" {
                    eventScanner = Scanner(string: event)
                    eventScanner.scanUpTo("DTEND;VALUE=DATE:", into: nil)
                    eventScanner.scanUpTo("\n", into: &endDateTimeStringPointer)
                    endDateTimeString = String(endDateTimeStringPointer ?? "")
                    endDateTimeString = endDateTimeString.replacingOccurrences(of: "DTEND;VALUE=DATE:", with: "").replacingOccurrences(of: "\r", with: "")
                }
            }

            // Extract timestamp
            eventScanner = Scanner(string: event)
            eventScanner.scanUpTo("DTSTAMP:", into: nil)
            eventScanner.scanUpTo("\n", into: &timeStampStringPointer)
            timeStampString = String(timeStampStringPointer ?? "")
            timeStampString = timeStampString.replacingOccurrences(of: "DTSTAMP:", with: "").replacingOccurrences(of: "\r", with: "")

            // Extract the unique ID
            eventScanner = Scanner(string: event)
            eventScanner.scanUpTo("UID:", into: nil)
            eventScanner.scanUpTo("\n", into: &eventUniqueIDStringPointer)
            eventUniqueIDString = String(eventUniqueIDStringPointer ?? "")
            eventUniqueIDString = eventUniqueIDString.replacingOccurrences(of: "UID:", with: "").replacingOccurrences(of: "\r", with: "")

            // Extract the attendees
            eventScanner = Scanner(string: event)
            var scannerStatus = Bool()
            repeat {
                var attendeeStringPointer: NSString?
                var attendeeString = String()
                if eventScanner.scanUpTo("ATTENDEE;", into: nil) {
                    scannerStatus = eventScanner.scanUpTo("\n", into: &attendeeStringPointer)
                    attendeeString = String(attendeeStringPointer ?? "")
                    if scannerStatus, attendeeString != "" {
                        attendeeString = attendeeString.replacingOccurrences(of: "ATTENDEE;", with: "").replacingOccurrences(of: "\r", with: "")
                        if let attendee = createAttendee(string: attendeeString) {
                            attendees.append(attendee)
                        }
                    }
                } else {
                    scannerStatus = false
                }
            } while scannerStatus

            // Extract the recurrance ID
            eventScanner = Scanner(string: event)
            eventScanner.scanUpTo(String(format: "RECURRENCE-ID;TZID=%@:", timezoneIDString), into: nil)
            eventScanner.scanUpTo("\n", into: &recurrenceIDStringPointer)
            recurrenceIDString = String(recurrenceIDStringPointer ?? "")
            recurrenceIDString = recurrenceIDString.replacingOccurrences(of: String(format: "RECURRENCE-ID;TZID=%@:", timezoneIDString), with: "").replacingOccurrences(of: "\r", with: "")

            // Extract the created datetime
            eventScanner = Scanner(string: event)
            eventScanner.scanUpTo("CREATED:", into: nil)
            eventScanner.scanUpTo("\n", into: &createdDateTimeStringPointer)
            createdDateTimeString = String(createdDateTimeStringPointer ?? "")
            createdDateTimeString = createdDateTimeString.replacingOccurrences(of: "CREATED:", with: "").replacingOccurrences(of: "\r", with: "")

            // Extract event description
            eventScanner = Scanner(string: event)
            eventScanner.scanUpTo("DESCRIPTION:", into: nil)
            eventScanner.scanUpTo("\n", into: &descriptionStringPointer)
            descriptionString = String(descriptionStringPointer ?? "")
            descriptionString = descriptionString.replacingOccurrences(of: "DESCRIPTION:", with: "").replacingOccurrences(of: "\r", with: "")

            // Extract last modified datetime
            eventScanner = Scanner(string: event)
            eventScanner.scanUpTo("LAST-MODIFIED:", into: nil)
            eventScanner.scanUpTo("\n", into: &lastModifiedDateTimeStringPointer)
            lastModifiedDateTimeString = String(lastModifiedDateTimeStringPointer ?? "")
            lastModifiedDateTimeString = lastModifiedDateTimeString.replacingOccurrences(of: "LAST-MODIFIED:", with: "").replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: "\r", with: "")

            // Extract the event location
            eventScanner = Scanner(string: event)
            eventScanner.scanUpTo("LOCATION:", into: nil)
            eventScanner.scanUpTo("\n", into: &locationStringPointer)
            locationString = String(locationStringPointer ?? "")
            locationString = locationString.replacingOccurrences(of: "LOCATION:", with: "").replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: "\r", with: "")

            // Extract the event sequence
            eventScanner = Scanner(string: event)
            eventScanner.scanUpTo("SEQUENCE:", into: nil)
            eventScanner.scanUpTo("\n", into: &sequenceStringPointer)
            sequenceString = String(sequenceStringPointer ?? "")
            sequenceString = sequenceString.replacingOccurrences(of: "SEQUENCE:", with: "").replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: "\r", with: "")

            // Extract the event status
            eventScanner = Scanner(string: event)
            eventScanner.scanUpTo("STATUS:", into: nil)
            eventScanner.scanUpTo("\n", into: &statusStringPointer)
            statusString = String(statusStringPointer ?? "")
            statusString = statusString.replacingOccurrences(of: "STATUS:", with: "").replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: "\r", with: "")

            // Extract the event summary
            eventScanner = Scanner(string: event)
            eventScanner.scanUpTo("SUMMARY:", into: nil)
            eventScanner.scanUpTo("\n", into: &summaryStringPointer)
            summaryString = String(summaryStringPointer ?? "")
            summaryString = summaryString.replacingOccurrences(of: "SUMMARY:", with: "").replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: "\r", with: "")

            // Extract the event transString
            eventScanner = Scanner(string: event)
            eventScanner.scanUpTo("TRANSP:", into: nil)
            eventScanner.scanUpTo("\n", into: &transStringPointer)
            transString = String(transStringPointer ?? "")
            transString = transString.replacingOccurrences(of: "TRANSP:", with: "").replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: "\r", with: "")

            // Extract the event repetition rules
            eventScanner = Scanner(string: event)
            eventScanner.scanUpTo("RRULE:", into: nil)
            eventScanner.scanUpTo("\n", into: &repetitionStringPointer)
            repetitionString = String(repetitionStringPointer ?? "")
            repetitionString = repetitionString.replacingOccurrences(of: "RRULE:", with: "").replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: "\r", with: "")

            // Extract the event exception rules
            eventScanner = Scanner(string: event)
            eventScanner.scanUpTo("EXRULE:", into: nil)
            eventScanner.scanUpTo("\n", into: &exceptionRuleStringPointer)
            exceptionRuleString = String(exceptionRuleStringPointer ?? "")
            exceptionRuleString = exceptionRuleString.replacingOccurrences(of: "EXRULE:", with: "").replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: "\r", with: "")

            // Set up scanner for
            eventScanner = Scanner(string: event)
            eventScanner.scanUpTo("EXDATE:", into: nil)

            while !eventScanner.isAtEnd {
                eventScanner.scanUpTo(":", into: nil)
                var exceptionStringPointer: NSString?
                var exceptionString = String()
                eventScanner.scanUpTo("\n", into: &exceptionStringPointer)
                exceptionString = String(exceptionStringPointer ?? "")
                exceptionString = exceptionString.replacingOccurrences(of: ":", with: "").replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: "\r", with: "")

                if exceptionString != "" {
                    exceptionDates.append(exceptionString)
                }

                eventScanner.scanUpTo("EXDATE;", into: nil)
            }

            let calendarEvent = MXLCalendarEvent(withStartDate: startDateTimeString,
                                         endDate: endDateTimeString,
                                         createdAt: createdDateTimeString,
                                         lastModified: lastModifiedDateTimeString,
                                         uniqueID: eventUniqueIDString,
                                         recurrenceID: recurrenceIDString,
                                         summary: summaryString,
                                         description: descriptionString,
                                         location: locationString,
                                         status: statusString,
                                         recurrenceRules: repetitionString,
                                         exceptionDates: exceptionDates,
                                         exceptionRules: exceptionRuleString,
                                         timeZoneIdentifier: timezoneIDString,
                                         attendees: attendees)

            calendar.add(event: calendarEvent)
        }
        callback(calendar, nil)
    }
}
