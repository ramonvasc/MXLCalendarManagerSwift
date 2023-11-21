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

/// Manages the parsing of iCalendar (.ics) format files.
/// Provides functionality to asynchronously load and parse calendar data from both remote URLs and local file paths.
public class MXLCalendarManager {

    /// Initializes a new instance of the calendar manager.
    public init() {}
    
    /// Enumerates potential errors that can occur during the parsing process.
    public enum CalendarError: Error {
        case invalidData
    }

    /// Asynchronously retrieves and parses an iCalendar file from a remote URL.
    /// - Parameters:
    ///   - fileURL: URL pointing to the remote .ics file.
    ///   - localeIdentifier: Identifier for locale-specific parsing (defaults to "en_US_POSIX").
    /// - Returns: An `MXLCalendar` instance representing the parsed calendar data.
    /// - Throws: An error if data retrieval or parsing fails.
    public func scanICSFileAtRemoteURL(fileURL: URL, localeIdentifier: String = "en_US_POSIX") async throws -> MXLCalendar {
        let (data, _) = try await URLSession.shared.data(from: fileURL)
        guard let fileString = String(data: data, encoding: .utf8) else {
            throw CalendarError.invalidData
        }
        return try await parse(icsString: fileString, localeIdentifier: localeIdentifier)
    }

    /// Asynchronously reads and parses an iCalendar file from a local file path.
    /// - Parameters:
    ///   - filePath: Path to the local .ics file.
    ///   - localeIdentifier: Identifier for locale-specific parsing (defaults to "en_US_POSIX").
    /// - Returns: An `MXLCalendar` instance representing the parsed calendar data.
    /// - Throws: An error if file reading or parsing fails.
    public func scanICSFileatLocalPath(filePath: String, localeIdentifier: String = "en_US_POSIX") async throws -> MXLCalendar {
        let calendarFile = try String(contentsOfFile: filePath, encoding: .utf8)
        return try await parse(icsString: calendarFile, localeIdentifier: localeIdentifier)
    }

    /// Extracts an attendee attribute from a given string based on the specified prefix.
    /// - Parameters:
    ///   - string: The string containing attendee information.
    ///   - attributePrefix: The prefix used to identify the start of the desired attribute.
    /// - Returns: The extracted attribute as a string.
    private func extractAttendeeAttribute(from string: String, attributePrefix: String) -> String {
        let scanner = Scanner(string: string)
        _ = scanner.scanUpToString(attributePrefix)
        guard let attribute = scanner.scanUpToString(";") else {
            return ""
        }
        return attribute.replacingOccurrences(of: attributePrefix, with: "")
    }

    /// Creates an attendee object from a string representation.
    /// - Parameter string: The string containing attendee information.
    /// - Returns: An `MXLCalendarAttendee` object if parsing is successful, otherwise `nil`.
    private func createAttendee(string: String) -> MXLCalendarAttendee? {
        let eventScanner = Scanner(string: string)
        guard let attributesString = eventScanner.scanUpToString(":"),
              let uriString = eventScanner.scanUpToString("\n") else {
            return nil
        }

        let uriIndex = uriString.index(uriString.startIndex, offsetBy: 1)
        let uri = String(uriString[uriIndex...])

        let role = extractAttendeeAttribute(from: attributesString, attributePrefix: "ROLE=")
        let comomName = extractAttendeeAttribute(from: attributesString, attributePrefix: "CN=")
        let partStat = extractAttendeeAttribute(from: attributesString, attributePrefix: "PARTSTAT=")

        guard let roleEnum = Role(rawValue: role),
              let partStatEnum = PartStat(rawValue: partStat) else {
            return nil
        }

        return MXLCalendarAttendee(withRole: roleEnum, commonName: comomName, andUri: uri, participantStatus: partStatEnum)
    }
    
    /// Parses an attribute from a given string starting and ending with specified patterns.
    /// - Parameters:
    ///   - string: The string to parse.
    ///   - patternStart: The starting pattern to identify the beginning of the attribute.
    ///   - patternEnd: The ending pattern to identify the end of the attribute.
    /// - Returns: The parsed attribute as a string.
    private func parseAttribute(from string: String, startingWith patternStart: String, endingWith patternEnd: String) -> String {
        let scanner = Scanner(string: string)
        _ = scanner.scanUpToString(patternStart)
        let parsedString = scanner.scanUpToString(patternEnd) ?? ""
        return parsedString.replacingOccurrences(of: patternStart, with: "").trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    /// Asynchronously parses an iCalendar formatted string into an `MXLCalendar` object.
    /// - Parameters:
    ///   - icsString: The iCalendar formatted string to be parsed.
    ///   - localeIdentifier: Locale identifier used for date parsing.
    /// - Returns: An `MXLCalendar` object constructed from the iCalendar string.
    /// - Throws: An error if parsing fails.
    public func parse(icsString: String, localeIdentifier: String = "en_US_POSIX") async throws -> MXLCalendar {
        // Regular expression setup to remove new lines
        // Splitting the ics string into events and parsing each event
        // For each event, extract various properties like start time, end time, attendees, etc.
        //
        // Once all events are parsed, the callback is called with the constructed `MXLCalendar`.
        var regex = NSRegularExpression()
        do {
            regex = try NSRegularExpression(pattern: "\n +", options: .caseInsensitive)
        } catch (let error) {
            throw(error)
        }

        let range = NSRange(location: 0, length: (icsString as NSString).length)
        let icsStringWithoutNewLines = regex.stringByReplacingMatches(in: icsString, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: range, withTemplate: "")

        // Pull out each line from the calendar file
        var eventsArray = icsStringWithoutNewLines.components(separatedBy: "BEGIN:VEVENT")
        let calendar = MXLCalendar()

        // Remove the first item (that's just all the stuff before the first VEVENT)
        if eventsArray.count > 0 {
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
            timezoneIDString = parseAttribute(from: event, startingWith: "DTSTART;TZID=", endingWith: ":")

            if timezoneIDString.isEmpty {
                // Extract event time zone ID
                timezoneIDString = parseAttribute(from: event, startingWith: "TZID:", endingWith: "\n")
            }

            // Extract start time
            startDateTimeString = parseAttribute(from: event, startingWith: String(format: "DTSTART;TZID=%@:", timezoneIDString), endingWith: "\n")

            if startDateTimeString.isEmpty {
                startDateTimeString = parseAttribute(from: event, startingWith: "DTSTART:", endingWith: "\n")

                if startDateTimeString.isEmpty {
                    startDateTimeString = parseAttribute(from: event, startingWith: "DTSTART;VALUE=DATE:", endingWith: "\n")
                }
            }

            // Extract end time
            endDateTimeString = parseAttribute(from: event, startingWith: String(format: "DTEND;TZID=%@:", timezoneIDString), endingWith: "\n")
            if endDateTimeString.isEmpty {
                endDateTimeString = parseAttribute(from: event, startingWith: "DTEND:", endingWith: "\n")
                if endDateTimeString.isEmpty {
                    endDateTimeString = parseAttribute(from: event, startingWith: "DTEND;VALUE=DATE:", endingWith: "\n")
                }
            }

            // Extract timestamp
            timeStampString = parseAttribute(from: event, startingWith: "DTSTAMP:", endingWith: "\n")

            // Extract the unique ID
            eventUniqueIDString = parseAttribute(from: event, startingWith: "UID:", endingWith: "\n")

            // Extract the attendees
            eventScanner = Scanner(string: event)
            var scannerStatus = Bool()
            repeat {
                var attendeeString = String()
                if eventScanner.scanUpToString("ATTENDEE;") != nil {
                    attendeeString = eventScanner.scanUpToString("\n") ?? ""
                    if !attendeeString.isEmpty {
                        scannerStatus = true
                        attendeeString = attendeeString.replacingOccurrences(of: "ATTENDEE;", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                        if let attendee = createAttendee(string: attendeeString) {
                            attendees.append(attendee)
                        }
                    }
                } else {
                    scannerStatus = false
                }
            } while scannerStatus

            // Extract the recurrance ID
            recurrenceIDString = parseAttribute(from: event, startingWith: String(format: "RECURRENCE-ID;TZID=%@:", timezoneIDString), endingWith: "\n")

            // Extract the created datetime
            createdDateTimeString = parseAttribute(from: event, startingWith: "CREATED:", endingWith: "\n")

            // Extract event description
            descriptionString = parseAttribute(from: event, startingWith: "DESCRIPTION:", endingWith: "\n")
            
            if descriptionString.isEmpty {
                eventScanner = Scanner(string: event)
                eventScanner.charactersToBeSkipped = nil
                _ = eventScanner.scanUpToString("DESCRIPTION;")
                _ = eventScanner.scanUpToString(":")
                _ = eventScanner.scanString(":")
                descriptionString = eventScanner.scanUpToString("\n") ?? ""
                descriptionString = descriptionString.replacingOccurrences(of: "DESCRIPTION;", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
            }

            // Extract last modified datetime
            lastModifiedDateTimeString = parseAttribute(from: event, startingWith: "LAST-MODIFIED:", endingWith: "\n")

            // Extract the event location
            locationString = parseAttribute(from: event, startingWith: "LOCATION:", endingWith: "\n")

            // Extract the event sequence
            sequenceString = parseAttribute(from: event, startingWith: "SEQUENCE:", endingWith: "\n")

            // Extract the event status
            statusString = parseAttribute(from: event, startingWith: "STATUS:", endingWith: "\n")
            
            // Extract the event summary
            summaryString = parseAttribute(from: event, startingWith: "SUMMARY:", endingWith: "\n")

            // Extract the event transString
            transString = parseAttribute(from: event, startingWith: "TRANSP:", endingWith: "\n")

            // Extract the event repetition rules
            repetitionString = parseAttribute(from: event, startingWith: "RRULE:", endingWith: "\n")

            // Extract the event exception rules
            exceptionRuleString = parseAttribute(from: event, startingWith: "EXRULE:", endingWith: "\n")

            // Set up scanner for EXDATE:
            eventScanner = Scanner(string: event)
            _ = eventScanner.scanUpToString("EXDATE:")

            while !eventScanner.isAtEnd {
                _ = eventScanner.scanUpToString(":")
                var exceptionString = String()
                exceptionString = eventScanner.scanUpToString("\n") ?? ""
                exceptionString = exceptionString.replacingOccurrences(of: ":", with: "").trimmingCharacters(in: .whitespacesAndNewlines)

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
                                                 sequence: sequenceString,
                                                 transparency: transString,
                                                 dtstamp: timeStampString,
                                                 recurrenceRules: repetitionString,
                                                 exceptionDates: exceptionDates,
                                                 exceptionRules: exceptionRuleString,
                                                 timeZoneIdentifier: timezoneIDString,
                                                 attendees: attendees,
                                                 localeIdentifier: localeIdentifier)

            calendar.add(event: calendarEvent)
        }
        
        return calendar
    }
}
