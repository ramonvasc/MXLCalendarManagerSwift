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

public class MXLCalendarManager {

    public init() {}

    public func scanICSFileAtRemoteURL(fileURL: URL, localeIdentifier: String = "en_US_POSIX", withCompletionHandler callback: @escaping (MXLCalendar?, Error?) -> Void) {

        var fileData = Data()
        DispatchQueue.global(qos: .default).async {
            do {
                fileData = try Data(contentsOf: fileURL)
            } catch (let downloadError) {
                callback(nil, downloadError)
                return
            }

            DispatchQueue.main.async {
                guard let fileString = String(data: fileData, encoding: .utf8) else {
                    return
                }
                self.parse(icsString: fileString, localeIdentifier: localeIdentifier, withCompletionHandler: callback)
            }
        }
    }

    public func scanICSFileatLocalPath(filePath: String, localeIdentifier: String = "en_US_POSIX", withCompletionHandler callback: @escaping (MXLCalendar?, Error?) -> Void) {
        var calendarFile = String()
        do {
            calendarFile = try String(contentsOfFile: filePath, encoding: .utf8)
        } catch (let fileError) {
            callback(nil, fileError)
            return
        }

        parse(icsString: calendarFile, localeIdentifier: localeIdentifier, withCompletionHandler: callback)
    }

    func createAttendee(string: String) -> MXLCalendarAttendee? {
        var eventScanner = Scanner(string: string)
        var uri = String()
        var role = String()
        var partStat = String()
        var comomName = String()
        var uriPointer: NSString?
        var attributesPointer: NSString?
        var holderPointer: NSString?

        attributesPointer = eventScanner.scanUpToString(":") as? NSString
        uriPointer = eventScanner.scanUpToString("\n") as? NSString
        if let uriPointer = uriPointer {
            uri = (uriPointer.substring(from: 1))
        }

        if let attributesPointer = attributesPointer {
            eventScanner = Scanner(string: attributesPointer as String)

            _ = eventScanner.scanUpToString("ROLE=")
            holderPointer = eventScanner.scanUpToString(";") as? NSString

            if let holderPointer = holderPointer {
                role = holderPointer.replacingOccurrences(of: "ROLE=", with: "")
            }

            eventScanner = Scanner(string: attributesPointer as String)
            if eventScanner.scanUpToString("CN=") != nil {
                holderPointer = eventScanner.scanUpToString(";") as? NSString
                if let holderPointer = holderPointer {
                    comomName = holderPointer.replacingOccurrences(of: "CN=", with: "")
                }
            }
            
            eventScanner = Scanner(string: attributesPointer as String)
            _ = eventScanner.scanUpToString("PARTSTAT=")
            holderPointer = eventScanner.scanUpToString(";") as? NSString
            
            if let holderPointer = holderPointer {
                partStat = holderPointer.replacingOccurrences(of: "PARTSTAT=", with: "")
            }
        }
        
        //ORGANIZER;CN=John Smith:MAILTO:jsmith@host.com
        //ATTENDEE;ROLE=REQ-PARTICIPANT;PARTSTAT=TENTATIVE;DELEGATED-FROM=
        // "MAILTO:iamboss@host2.com";CN=Henry Cabot:MAILTO:hcabot@
        // host2.com
        //ATTENDEE;ROLE=NON-PARTICIPANT;PARTSTAT=DELEGATED;DELEGATED-TO=
        // "MAILTO:hcabot@host2.com";CN=The Big Cheese:MAILTO:iamboss
        // @host2.com
        //ATTENDEE;ROLE=REQ-PARTICIPANT;PARTSTAT=ACCEPTED;CN=Jane Doe
        // :MAILTO:jdoe@host1.com
        guard let roleEnum = Role(rawValue: role) else {
            return nil
        }
        
        guard let partStatEnum = PartStat(rawValue: partStat) else {
            return nil
        }

        return MXLCalendarAttendee(withRole: roleEnum, commonName: comomName, andUri: uri, participantStatus: partStatEnum)
    }

    public func parse(icsString: String, localeIdentifier: String, withCompletionHandler callback: @escaping (MXLCalendar?, Error?) -> Void) {
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
            _ = scanner.scanUpToString("TZID:") as? NSString
            calendarStringPointer = scanner.scanUpToString("\n") as? NSString
            calendarString = String(calendarStringPointer ?? "")
            calendarString = calendarString.replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: "\r", with: "").replacingOccurrences(of: "TZID", with: "")

            eventsArray.remove(at: 0)
        }

        var eventScanner = Scanner()

        // For each event, extract the data
        for event in eventsArray {
            var timezoneIDString = String()
            var startDateTimeString = String()
            var endDateTimeString = String()
            var eventUniqueIDString = String()
            var recurrenceIDString = String()
            var createdDateTimeString = String()
            var descriptionString = String()
            var lastModifiedDateTimeString = String()
            var locationString = String()
            var sequenceString = String()
            var statusString = String()
            var summaryString = String()
            var transString = String()
            var timeStampString = String()
            var repetitionString = String()
            var exceptionRuleString = String()
            var exceptionDates = [String]()
            var attendees = [MXLCalendarAttendee]()

            // Extract event time zone ID
            eventScanner = Scanner(string: event)
            _ = eventScanner.scanUpToString("DTSTART;TZID=")
            timezoneIDString = eventScanner.scanUpToString(":") ?? ""
            timezoneIDString = timezoneIDString.replacingOccurrences(of: "DTSTART;TZID=", with: "").replacingOccurrences(of: "\n", with: "")

            if timezoneIDString.isEmpty {
                // Extract event time zone ID
                eventScanner = Scanner(string: event)
                _ = eventScanner.scanUpToString("TZID:")
                timezoneIDString = eventScanner.scanUpToString("\n") ?? ""
                timezoneIDString = timezoneIDString.replacingOccurrences(of: "TZID:", with: "").replacingOccurrences(of: "\n", with: "")
            }

            // Extract start time
            eventScanner = Scanner(string: event)
            _ = eventScanner.scanUpToString(String(format: "DTSTART;TZID=%@:", timezoneIDString))
            startDateTimeString = eventScanner.scanUpToString("\n") ?? ""
            startDateTimeString = startDateTimeString.replacingOccurrences(of: String(format: "DTSTART;TZID=%@:", timezoneIDString), with: "").replacingOccurrences(of: "\r", with: "")

            if startDateTimeString.isEmpty {
                eventScanner = Scanner(string: event)
                _ = eventScanner.scanUpToString("DTSTART:")
                startDateTimeString = eventScanner.scanUpToString("\n") ?? ""
                startDateTimeString = startDateTimeString.replacingOccurrences(of: "DTSTART:", with: "").replacingOccurrences(of: "\r", with: "")

                if startDateTimeString.isEmpty {
                    eventScanner = Scanner(string: event)
                    _ = eventScanner.scanUpToString("DTSTART;VALUE=DATE:")
                    startDateTimeString = eventScanner.scanUpToString("\n") ?? ""
                    startDateTimeString = startDateTimeString.replacingOccurrences(of: "DTSTART;VALUE=DATE:", with: "").replacingOccurrences(of: "\r", with: "")
                }
            }

            // Extract end time
            eventScanner = Scanner(string: event)
            _ = eventScanner.scanUpToString(String(format: "DTEND;TZID=%@:", timezoneIDString))
            endDateTimeString = eventScanner.scanUpToString("\n") ?? ""
            endDateTimeString = endDateTimeString.replacingOccurrences(of: String(format: "DTEND;TZID=%@:", timezoneIDString), with: "").replacingOccurrences(of: "\r", with: "")

            if endDateTimeString.isEmpty {
                eventScanner = Scanner(string: event)
                _ = eventScanner.scanUpToString("DTEND:")
                endDateTimeString = eventScanner.scanUpToString("\n") ?? ""
                endDateTimeString = endDateTimeString.replacingOccurrences(of: "DTEND:", with: "").replacingOccurrences(of: "\r", with: "")

                if endDateTimeString.isEmpty {
                    eventScanner = Scanner(string: event)
                    _ = eventScanner.scanUpToString("DTEND;VALUE=DATE:")
                    endDateTimeString = eventScanner.scanUpToString("\n") ?? ""
                    endDateTimeString = endDateTimeString.replacingOccurrences(of: "DTEND;VALUE=DATE:", with: "").replacingOccurrences(of: "\r", with: "")
                }
            }

            // Extract timestamp
            eventScanner = Scanner(string: event)
            _ = eventScanner.scanUpToString("DTSTAMP:")
            timeStampString = eventScanner.scanUpToString("\n") ?? ""
            timeStampString = timeStampString.replacingOccurrences(of: "DTSTAMP:", with: "").replacingOccurrences(of: "\r", with: "")

            // Extract the unique ID
            eventScanner = Scanner(string: event)
            _ = eventScanner.scanUpToString("UID:")
            eventUniqueIDString = eventScanner.scanUpToString("\n") ?? ""
            eventUniqueIDString = eventUniqueIDString.replacingOccurrences(of: "UID:", with: "").replacingOccurrences(of: "\r", with: "")

            // Extract the attendees
            eventScanner = Scanner(string: event)
            var scannerStatus = Bool()
            repeat {
                var attendeeString = String()
                if eventScanner.scanUpToString("ATTENDEE;") != nil {
                    attendeeString = eventScanner.scanUpToString("\n") ?? ""
                    if !attendeeString.isEmpty {
                        scannerStatus = true
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
            _ = eventScanner.scanUpToString(String(format: "RECURRENCE-ID;TZID=%@:", timezoneIDString))
            recurrenceIDString = eventScanner.scanUpToString("\n") ?? ""
            recurrenceIDString = recurrenceIDString.replacingOccurrences(of: String(format: "RECURRENCE-ID;TZID=%@:", timezoneIDString), with: "").replacingOccurrences(of: "\r", with: "")

            // Extract the created datetime
            eventScanner = Scanner(string: event)
            _ = eventScanner.scanUpToString("CREATED:")
            createdDateTimeString = eventScanner.scanUpToString("\n") ?? ""
            createdDateTimeString = createdDateTimeString.replacingOccurrences(of: "CREATED:", with: "").replacingOccurrences(of: "\r", with: "")

            // Extract event description
            eventScanner = Scanner(string: event)
            _ = eventScanner.scanUpToString("DESCRIPTION:")
            descriptionString = eventScanner.scanUpToString("\n") ?? ""
            descriptionString = descriptionString.replacingOccurrences(of: "DESCRIPTION:", with: "").replacingOccurrences(of: "\r", with: "")

            // Extract last modified datetime
            eventScanner = Scanner(string: event)
            _ = eventScanner.scanUpToString("LAST-MODIFIED:")
            lastModifiedDateTimeString = eventScanner.scanUpToString("\n") ?? ""
            lastModifiedDateTimeString = lastModifiedDateTimeString.replacingOccurrences(of: "LAST-MODIFIED:", with: "").replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: "\r", with: "")

            // Extract the event location
            eventScanner = Scanner(string: event)
            _ = eventScanner.scanUpToString("LOCATION:")
            locationString = eventScanner.scanUpToString("\n") ?? ""
            locationString = locationString.replacingOccurrences(of: "LOCATION:", with: "").replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: "\r", with: "")

            // Extract the event sequence
            eventScanner = Scanner(string: event)
            _ = eventScanner.scanUpToString("SEQUENCE:")
            sequenceString = eventScanner.scanUpToString("\n") ?? ""
            sequenceString = sequenceString.replacingOccurrences(of: "SEQUENCE:", with: "").replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: "\r", with: "")

            // Extract the event status
            eventScanner = Scanner(string: event)
            _ = eventScanner.scanUpToString("STATUS:")
            statusString = eventScanner.scanUpToString("\n") ?? ""
            statusString = statusString.replacingOccurrences(of: "STATUS:", with: "").replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: "\r", with: "")

            // Extract the event summary
            eventScanner = Scanner(string: event)
            _ = eventScanner.scanUpToString("SUMMARY:")
            summaryString = eventScanner.scanUpToString("\n") ?? ""
            summaryString = summaryString.replacingOccurrences(of: "SUMMARY:", with: "").replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: "\r", with: "")

            // Extract the event transString
            eventScanner = Scanner(string: event)
            _ = eventScanner.scanUpToString("TRANSP:")
            transString = eventScanner.scanUpToString("\n") ?? ""
            transString = transString.replacingOccurrences(of: "TRANSP:", with: "").replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: "\r", with: "")

            // Extract the event repetition rules
            eventScanner = Scanner(string: event)
            _ = eventScanner.scanUpToString("RRULE:")
            repetitionString = eventScanner.scanUpToString("\n") ?? ""
            repetitionString = repetitionString.replacingOccurrences(of: "RRULE:", with: "").replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: "\r", with: "")

            // Extract the event exception rules
            eventScanner = Scanner(string: event)
            _ = eventScanner.scanUpToString("EXRULE:")
            exceptionRuleString = eventScanner.scanUpToString("\n") ?? ""
            exceptionRuleString = exceptionRuleString.replacingOccurrences(of: "EXRULE:", with: "").replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: "\r", with: "")

            // Set up scanner for
            eventScanner = Scanner(string: event)
            _ = eventScanner.scanUpToString("EXDATE:")

            while !eventScanner.isAtEnd {
                _ = eventScanner.scanUpToString(":")
                var exceptionString = String()
                exceptionString = eventScanner.scanUpToString("\n") ?? ""
                exceptionString = exceptionString.replacingOccurrences(of: ":", with: "").replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: "\r", with: "")

                if !exceptionString.isEmpty {
                    exceptionDates.append(exceptionString)
                }

                _ = eventScanner.scanUpToString("EXDATE;")
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
                                                 attendees: attendees,
                                                 localeIdentifier: localeIdentifier)

            calendar.add(event: calendarEvent)
        }
        callback(calendar, nil)
    }
}
