//
//  MXLCalendarEvent.swift
//  Pods
//
//  Created by Ramon Vasconcelos on 22/08/2017.
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
import EventKit

// Constants defining various frequency types for calendar events
let DAILY_FREQUENCY = "DAILY"
let WEEKLY_FREQUENCY = "WEEKLY"
let MONTHLY_FREQUENCY = "MONTHLY"
let YEARLY_FREQUENCY = "YEARLY"

// Enumeration defining the types of rules for calendar events: Repetition or Exception
public enum MXLCalendarEventRuleType {
    case MXLCalendarEventRuleTypeRepetition
    case MXLCalendarEventRuleTypeException
}

/// Represents an event in a calendar, supporting recurrence rules, exceptions, and other properties typical of iCalendar events.
public class MXLCalendarEvent {
    // MARK: - Properties
    
    // DateFormatter used for parsing and formatting event-related dates
    public internal(set) var dateFormatter: DateFormatter

    // Properties related to exception rules (exRule) for the calendar event
    public internal(set) var exRuleFrequency: String?
    public internal(set) var exRuleCount: String?
    public internal(set) var exRuleRuleWkSt: String?
    public internal(set) var exRuleInterval: String?
    public internal(set) var exRuleWeekStart: String?
    public internal(set) var exRuleUntilDate: Date?

    public internal(set) var exRuleBySecond: [String]?
    public internal(set) var exRuleByMinute: [String]?
    public internal(set) var exRuleByHour: [String]?
    public internal(set) var exRuleByDay: [String]?
    public internal(set) var exRuleByMonthDay: [String]?
    public internal(set) var exRuleByYearDay: [String]?
    public internal(set) var exRuleByWeekNo: [String]?
    public internal(set) var exRuleByMonth: [String]?
    public internal(set) var exRuleBySetPos: [String]?

    // Properties related to repetition rules (repeatRule) for the calendar event
    public internal(set) var repeatRuleFrequency: String?
    public internal(set) var repeatRuleCount: String?
    public internal(set) var repeatRuleRuleWkSt: String?
    public internal(set) var repeatRuleInterval: String?
    public internal(set) var repeatRuleWeekStart: String?
    public internal(set) var repeatRuleUntilDate: Date?

    public internal(set) var repeatRuleBySecond: [String]?
    public internal(set) var repeatRuleByMinute: [String]?
    public internal(set) var repeatRuleByHour: [String]?
    public internal(set) var repeatRuleByDay: [String]?
    public internal(set) var repeatRuleByMonthDay: [String]?
    public internal(set) var repeatRuleByYearDay: [String]?
    public internal(set) var repeatRuleByWeekNo: [String]?
    public internal(set) var repeatRuleByMonth: [String]?
    public internal(set) var repeatRuleBySetPos: [String]?

    // Collection of dates on which the event should not occur
    public internal(set) var eventExceptionDates: [Date] = [Date]()

    // Calendar used to manage date and time values
    public internal(set) var calendar: Calendar?

    // Properties representing the event's date and time characteristics
    public internal(set) var eventStartDate: Date?
    public internal(set) var eventEndDate: Date?
    public internal(set) var eventCreatedDate: Date?
    public internal(set) var eventLastModifiedDate: Date?
    public internal(set) var eventIsAllDay: Bool?

    // Properties representing the unique identifiers and descriptive details of the event
    public internal(set) var eventUniqueID: String?
    public internal(set) var eventRecurrenceID: String?
    public internal(set) var eventSummary: String?
    public internal(set) var eventDescription: String?
    public internal(set) var eventLocation: String?
    public internal(set) var eventStatus: String?
    public internal(set) var sequence: String?
    public internal(set) var transparency: String?
    public internal(set) var dtstamp: String?
    public internal(set) var attendees: [MXLCalendarAttendee]?

    public internal(set) var rruleString: String?

    // MARK: - Initialization

    /// Initializes a new calendar event with detailed properties.
    /// - Parameters:
    ///   - startString: Start date and time as a string.
    ///   - endString: End date and time as a string.
    ///   - createdString: Creation date and time as a string.
    ///   - lastModifiedString: Last modified date and time as a string.
    ///   - uniqueID: Unique identifier of the event.
    ///   - recurrenceID: Identifier for the recurrence rule.
    ///   - summary: Summary or title of the event.
    ///   - description: Description of the event.
    ///   - location: Location of the event.
    ///   - status: Status of the event (e.g., confirmed, tentative).
    ///   - sequence: Sequence number of the event.
    ///   - transparency: Transparency of the event.
    ///   - dtstamp: Timestamp of the event creation.
    ///   - recurrenceRules: Recurrence rules as a string.
    ///   - exceptionDates: Array of exception dates as strings.
    ///   - exceptionRules: Exception rules as a string.
    ///   - timeZoneIdentifier: Identifier of the event's time zone.
    ///   - attendees: Array of attendees for the event.
    ///   - localeIdentifier: Locale identifier used for date parsing.
    public init(withStartDate startString: String,
                endDate endString: String,
                createdAt createdString: String,
                lastModified lastModifiedString: String,
                uniqueID: String,
                recurrenceID: String,
                summary: String,
                description: String,
                location: String,
                status: String,
                sequence: String,
                transparency: String,
                dtstamp: String,
                recurrenceRules: String,
                exceptionDates: [String],
                exceptionRules: String,
                timeZoneIdentifier: String,
                attendees: [MXLCalendarAttendee],
                localeIdentifier: String) {
        self.calendar = Calendar(identifier: .gregorian)
        self.dateFormatter = DateFormatter()
        self.dateFormatter.locale = Locale(identifier: localeIdentifier)
        self.dateFormatter.timeZone = TimeZone(identifier: timeZoneIdentifier.isEmpty ? "GMT" : timeZoneIdentifier)
        calendar?.timeZone = dateFormatter.timeZone
        self.dateFormatter.dateFormat = "yyyyMMdd HHmmss"
        self.eventStartDate = dateFromString(dateString: startString)
        self.eventEndDate = dateFromString(dateString: endString)
        self.eventCreatedDate = dateFromString(dateString: createdString)
        self.eventLastModifiedDate = dateFromString(dateString: lastModifiedString)
        self.eventExceptionDates = exceptionDates
            .compactMap({ (exceptionDateString) -> Date? in
                return self.dateFromString(dateString: exceptionDateString)
            })

        self.rruleString = recurrenceRules

        parseRules(rule: recurrenceRules, forType: .MXLCalendarEventRuleTypeRepetition)
        parseRules(rule: exceptionRules, forType: .MXLCalendarEventRuleTypeException)

        self.eventUniqueID = uniqueID
        self.eventRecurrenceID = recurrenceID
        self.eventSummary = summary.replacingOccurrences(of: "\\", with: "")
        self.eventDescription = description.replacingOccurrences(of: "\\", with: "")
        self.eventLocation = location.replacingOccurrences(of: "\\", with: "")
        self.eventStatus = status
        self.sequence = sequence
        self.transparency = transparency
        self.dtstamp = dtstamp
        self.attendees = attendees

    }

    
    // MARK: - Helper Methods
    
    /// Converts a string representation of a date into a `Date` object.
    /// - Parameter dateString: The date string to be converted.
    /// - Returns: A `Date` object if the conversion is successful; otherwise, `nil`.
    public func dateFromString(dateString: String) -> Date? {
        var date: Date?
        let dateString = dateString.replacingOccurrences(of: "T", with: " ")
        let containsZone = dateString.range(of: "z", options: .caseInsensitive) != nil

        if containsZone {
            dateFormatter.dateFormat = "yyyyMMdd HHmmssz"
        }

        date = dateFormatter.date(from: dateString)

        if date == nil {
            if containsZone {
                dateFormatter.dateFormat = "yyyyMMddz"
            } else {
                dateFormatter.dateFormat = "yyyyMMdd"
            }

            date = dateFormatter.date(from: dateString)

            if date != nil {
                eventIsAllDay = true
            }
        }

        dateFormatter.dateFormat = "yyyyMMdd HHmmss"

        return date

    }

    /// Parses a rule from a given string starting and ending with specified patterns.
    /// - Parameters:
    ///   - string: The string to parse.
    ///   - patternStart: The starting pattern to identify the beginning of the attribute.
    ///   - patternEnd: The ending pattern to identify the end of the attribute.
    /// - Returns: The parsed rule as a string.
    private func parseRule(from string: String, startingWith patternStart: String, endingWith patternEnd: String) -> String {
        let scanner = Scanner(string: string)
        _ = scanner.scanUpToString(patternStart)
        let parsedString = scanner.scanUpToString(patternEnd) ?? ""
        return parsedString.replacingOccurrences(of: patternStart, with: "").trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    /// Parses a rule string and updates event properties based on the rule type.
    /// - Parameters:
    ///   - rule: The rule string to be parsed.
    ///   - type: The type of the rule (repetition or exception).
    public func parseRules(rule: String, forType type: MXLCalendarEventRuleType) {
        let rulesArray = rule.components(separatedBy: ";") // Split up rules string into array

        var frequency = String()
        var count = String()
        var untilString = String()
        var interval = String()
        var byDay = String()
        var byMonthDay = String()
        var byYearDay = String()
        var byWeekNo = String()
        var byMonth = String()
        var weekStart = String()

        // Loop through each rule
        for rule in rulesArray {
            // If the rule is for the FREQuency
            if rule.range(of: "FREQ") != nil {
                frequency = parseRule(from: rule, startingWith: "=", endingWith: ";")

                if type == .MXLCalendarEventRuleTypeRepetition {
                    repeatRuleFrequency = frequency
                } else {
                    exRuleFrequency = frequency
                }
            }

            // If the rule is COUNT
            if rule.range(of: "COUNT") != nil {
                count = parseRule(from: rule, startingWith: "=", endingWith: ";")

                if type == . MXLCalendarEventRuleTypeRepetition {
                    repeatRuleCount = count
                } else {
                    exRuleCount = count
                }
            }

            // If the rule is for the UNTIL date
            if rule.range(of: "UNTIL") != nil {
                untilString = parseRule(from: rule, startingWith: "=", endingWith: ";")

                if type == .MXLCalendarEventRuleTypeRepetition {
                    repeatRuleUntilDate = dateFromString(dateString: untilString)
                } else {
                    exRuleUntilDate = dateFromString(dateString: untilString)
                }
            }

            // If the rule is INTERVAL
            if rule.range(of: "INTERVAL") != nil {
                interval = parseRule(from: rule, startingWith: "=", endingWith: ";")

                if type == . MXLCalendarEventRuleTypeRepetition {
                    repeatRuleInterval = interval
                } else {
                    exRuleInterval = interval
                }
            }

            // If the rule is BYDAY
            if rule.range(of: "BYDAY") != nil {
                byDay = parseRule(from: rule, startingWith: "=", endingWith: ";")

                if type == . MXLCalendarEventRuleTypeRepetition {
                    repeatRuleByDay = byDay.components(separatedBy: ",")
                } else {
                    exRuleByDay = byDay.components(separatedBy: ",")
                }
            }

            // If the rule is BYMONTHDAY
            if rule.range(of: "BYMONTHDAY") != nil {
                byMonthDay = parseRule(from: rule, startingWith: "=", endingWith: ";")

                if type == . MXLCalendarEventRuleTypeRepetition {
                    repeatRuleByMonthDay = byMonthDay.components(separatedBy: ",")
                } else {
                    exRuleByMonthDay = byMonthDay.components(separatedBy: ",")
                }
            }

            // If the rule is BYYEARDAY
            if rule.range(of: "BYYEARDAY") != nil {
                byYearDay = parseRule(from: rule, startingWith: "=", endingWith: ";")

                if type == . MXLCalendarEventRuleTypeRepetition {
                    repeatRuleByYearDay = byYearDay.components(separatedBy: ",")
                } else {
                    exRuleByYearDay = byYearDay.components(separatedBy: ",")
                }
            }

            // If the rule is BYWEEKNO
            if rule.range(of: "BYWEEKNO") != nil {
                byWeekNo = parseRule(from: rule, startingWith: "=", endingWith: ";")

                if type == . MXLCalendarEventRuleTypeRepetition {
                    repeatRuleByWeekNo = byWeekNo.components(separatedBy: ",")
                } else {
                    exRuleByWeekNo = byWeekNo.components(separatedBy: ",")
                }
            }

            // If the rule is BYMONTH
            if rule.range(of: "BYMONTH=") != nil {
                byMonth = parseRule(from: rule, startingWith: "=", endingWith: ";")

                if type == . MXLCalendarEventRuleTypeRepetition {
                    repeatRuleByMonth = byMonth.components(separatedBy: ",")
                } else {
                    exRuleByMonth = byMonth.components(separatedBy: ",")
                }
            }

            // If the rule is WKST
            if rule.range(of: "WKST") != nil {
                weekStart = parseRule(from: rule, startingWith: "=", endingWith: ";")

                if type == . MXLCalendarEventRuleTypeRepetition {
                    repeatRuleWeekStart = weekStart
                } else {
                    exRuleWeekStart = weekStart
                }
            }
        }
    }

    /// Checks if the event occurs on a specified day, month, and year.
    /// - Parameters:
    ///   - day: The day to check.
    ///   - month: The month to check.
    ///   - year: The year to check.
    /// - Returns: `true` if the event occurs on the specified date; otherwise, `false`.
    public func check(day: Int, month: Int, year: Int) -> Bool {
        guard var components = calendar?.dateComponents([.day, .month, .year], from: Date()) else {
            return false
        }
        components.day = day
        components.month = month
        components.year = year

        return checkDate(date: calendar?.date(from: components))

    }

    /// Determines if the event occurs on a given date.
    /// - Parameter date: The date to check for the event's occurrence.
    /// - Returns: `true` if the event occurs on the specified date; otherwise, `false`.
    public func checkDate(date: Date?) -> Bool {
        guard let date = date, let eventStartDate = eventStartDate, let eventEndDate = eventEndDate else {
            return false
        }

        // If the event starts in the future
        if eventStartDate.compare(date) == .orderedDescending {
            return false
        }

        // If the event does not repeat, the 'date' must be the event's start date for event to occur on this date
        if repeatRuleFrequency == nil {

            // Load date into DateComponent from the Calendar instance
            let difference = calendar?.dateComponents([.day, .month, .year, .hour, .minute, .second], from: eventStartDate, to: date)

            // Check if the event's start date is equal to the provided date
            if difference?.day == 0, difference?.month == 0, difference?.year == 0, difference?.hour == 0, difference?.minute == 0, difference?.second == 0 {
                return exceptionOn(date: date) ? false : true // Check if there's an exception rule covering this date. Return accordingly
            } else {
                return false // Event won't occur on this date
            }
        }

        guard let calendar = calendar else {
            return false
        }

        // If the date is in the event's exception dates, event won't occur
        if eventExceptionDates.contains(where: { calendar.isDate(date, inSameDayAs: $0) }) {
            return false
        }

        // Extract the components from the provided date
        let components = calendar.dateComponents([.day, .weekOfYear, .month, .year, .weekday], from: date)

        guard let day = components.day, let month = components.month, let weekday = components.weekday, let weekOfYear = components.weekOfYear, let dayOfYear = calendar.ordinality(of: .day, in: .year, for: date) else {
            return false
        }

        let dayString = dayOfWeekFromInteger(day: weekday)

        let weekNumberString = String(format: "%li", weekOfYear)
        let monthString = String(format: "%li", month)

        // If the event is set to repeat on a certain day of the week, it MUST be the current date's weekday for it to occur
        if let repeatRuleByDay = repeatRuleByDay, !repeatRuleByDay.contains(dayString) {
            // These checks are to catch if the event is set to repeat on a particular weekday of the month (e.g., every third Sunday)
            if !repeatRuleByDay.contains(String(format: "1%@", dayString)), !repeatRuleByDay.contains(String(format: "2%@", dayString)), !repeatRuleByDay.contains(String(format: "3%@", dayString)) {
                return false
            }
        }

        // Same as above (and bellow)
        if let repeatRuleByMonthDay = repeatRuleByMonthDay, !repeatRuleByMonthDay.contains(String(format: "%li", day)) {
            return false
        }

        if let repeatRuleByYearDay = repeatRuleByYearDay, !repeatRuleByYearDay.contains(String(format: "%li", dayOfYear)) {
            return false
        }

        if let repeatRuleByWeekNo = repeatRuleByWeekNo, !repeatRuleByWeekNo.contains(weekNumberString) {
            return false
        }

        if let repeatRuleByMonth = repeatRuleByMonth, !repeatRuleByMonth.contains(monthString) {
            return false
        }

        // If there's no repetition interval provided, it means the interval = 1.
        // We explicitly set it to "1" for use in calculations below
        repeatRuleInterval = repeatRuleInterval ?? "1"

        guard let repeatRuleInterval = repeatRuleInterval, let repeatRuleIntervalInt = Int(repeatRuleInterval) else {
            return false
        }

        // If it's set to repeat every week...
        if repeatRuleFrequency == WEEKLY_FREQUENCY {
            // Is there a limit on the number of repetitions
            // (e.g., event repeats for the 3 occurrences after it first occurred)
            if let repeatRuleCount = repeatRuleCount, let repeatRuleCountInt = Int(repeatRuleCount) {
                // Get the number of weeks from the first occurrence until the last one, then multiply by 7 days a week
                let daysUntilLastOccurrence = (repeatRuleCountInt - 1) * repeatRuleIntervalInt * 7
                var comp = DateComponents()
                comp.day = daysUntilLastOccurrence

                // Create a date by adding the number of days until the final occurrence onto the first occurrence
                guard let maximumDate = calendar.date(byAdding: comp, to: eventEndDate) else {
                    return false
                }

                // If the final possible occurrence is in the future...
                if maximumDate.compare(date) == .orderedDescending || maximumDate.compare(date) == .orderedSame {
                    // Get the number of weeks between the final date and current date

                    if let difference = calendar.dateComponents([.day], from: maximumDate, to: date).day {
                        if difference % repeatRuleIntervalInt != 0 {
                            return false
                        } else {
                            return true
                        }
                    }
                } else {
                    return false
                }
            } else if let repeatRuleUntilDate = repeatRuleUntilDate {
                if repeatRuleUntilDate.compare(date) == .orderedDescending || repeatRuleUntilDate.compare(date) == .orderedSame, let difference = calendar.dateComponents([.day], from: repeatRuleUntilDate, to: date).day {
                    if difference % repeatRuleIntervalInt != 0 {
                        return false
                    } else {
                        return true
                    }
                } else {
                    return false
                }
            } else if let difference = calendar.dateComponents([.day], from: eventStartDate, to: date).day {
                if difference % repeatRuleIntervalInt != 0 {
                    return false
                } else {
                    return true
                }
            }
        } else if repeatRuleFrequency == DAILY_FREQUENCY {
            if let repeatRuleCount = repeatRuleCount, let repeatRuleCountInt = Int(repeatRuleCount) {
                // Get the number of days from the first occurrence until the last one
                let daysUntilLastOccurrence = (repeatRuleCountInt - 1) * repeatRuleIntervalInt
                var comp = DateComponents()
                comp.day = daysUntilLastOccurrence
                
                // Create a date by adding the number of days until the final occurrence onto the first occurrence
                guard let maximumDate = calendar.date(byAdding: comp, to: eventEndDate) else {
                    return false
                }
                
                // If the final possible occurrence is in the future...
                if maximumDate.compare(date) == .orderedDescending || maximumDate.compare(date) == .orderedSame {
                    // Get the number of weeks between the final date and current date
                    
                    if let difference = calendar.dateComponents([.day], from: maximumDate, to: date).day {
                        if difference % repeatRuleIntervalInt != 0 {
                            return false
                        } else {
                            return true
                        }
                    }
                } else {
                    return false
                }
            } else if let repeatRuleUntilDate = repeatRuleUntilDate {
                if repeatRuleUntilDate.compare(date) == .orderedDescending || repeatRuleUntilDate.compare(date) == .orderedSame, let difference = calendar.dateComponents([.day], from: repeatRuleUntilDate, to: date).day {
                    if difference % repeatRuleIntervalInt != 0 {
                        return false
                    } else {
                        return true
                    }
                } else {
                    return false
                }
            } else if let difference = calendar.dateComponents([.day], from: eventStartDate, to: date).day {
                if difference % repeatRuleIntervalInt != 0 {
                    return false
                } else {
                    return true
                }
            }
        } else if repeatRuleFrequency == MONTHLY_FREQUENCY {
            if let repeatRuleCount = repeatRuleCount, let repeatRuleCountInt = Int(repeatRuleCount) {
                let monthsUntilLastOccurrence = (repeatRuleCountInt - 1) * repeatRuleIntervalInt

                var comp = DateComponents()
                comp.month = monthsUntilLastOccurrence

                let maximumDate = calendar.date(byAdding: comp, to: eventEndDate)
                if maximumDate?.compare(date) == .orderedDescending || maximumDate?.compare(date) == .orderedSame, let calendarDate = calendar.date(from: comp), let difference = calendar.dateComponents([.month], from: calendarDate, to: date).month {
                    if difference % repeatRuleIntervalInt != 0 {
                        return false
                    } else {
                        return true
                    }
                } else {
                    return false
                }
            } else if let repeatRuleUntilDate = repeatRuleUntilDate {
                if repeatRuleUntilDate.compare(date) == .orderedDescending || repeatRuleUntilDate.compare(date) == .orderedSame, let difference = calendar.dateComponents([.month], from: repeatRuleUntilDate, to: date).month {
                    if difference % repeatRuleIntervalInt != 0 {
                        return false
                    } else {
                        return true
                    }
                } else {
                    return false
                }
            } else {
                if let difference = calendar.dateComponents([.day], from: eventStartDate, to: date).month, difference % repeatRuleIntervalInt != 0 {
                    return false
                } else {
                    return true
                }
            }
        } else if repeatRuleFrequency == YEARLY_FREQUENCY {
            if let repeatRuleCount = repeatRuleCount, let repeatRuleCountInt = Int(repeatRuleCount) {
                let yearsUntilLastOccurrence = (repeatRuleCountInt - 1) * repeatRuleIntervalInt
                var comp = DateComponents()
                comp.year = yearsUntilLastOccurrence

                let maximumDate = calendar.date(byAdding: comp, to: eventEndDate)

                if maximumDate?.compare(date) == .orderedDescending || maximumDate?.compare(date) == .orderedSame, let calendarDate = calendar.date(from: comp), let difference = calendar.dateComponents([.year], from:calendarDate, to: date).year {
                    if difference % repeatRuleIntervalInt != 0 {
                        return false
                    } else {
                        return true
                    }
                }
            } else if let repeatRuleUntilDate = repeatRuleUntilDate {
                if repeatRuleUntilDate.compare(date) == .orderedDescending || repeatRuleUntilDate.compare(date) == .orderedSame, let difference = calendar.dateComponents([.year], from: repeatRuleUntilDate, to: date).year {
                    if difference % repeatRuleIntervalInt != 0 {
                        return false
                    } else {
                        return true
                    }
                } else {
                    return false
                }
            } else {
                if let difference = calendar.dateComponents([.year], from: eventStartDate, to: date).year {
                    if difference % repeatRuleIntervalInt != 0 {
                        return false
                    } else {
                        return true
                    }
                }
            }
        } else {
            return false
        }

        return false

    }

    /// Evaluates if a given date is an exception to the event's occurrence.
    /// - Parameter date: The date to check for an exception.
    /// - Returns: `true` if the date is an exception; otherwise, `false`.
    public func exceptionOn(date: Date) -> Bool {
        // If the event does not repeat, the 'date' must be the event's start date for event to occur on this date
        if exRuleFrequency == nil {
            return false
        }

        // If the date is in the event's exception dates, event won't occur
        if eventExceptionDates.contains(date) {
            return false
        }

        guard let calendar = calendar else {
            return false
        }

        let components = calendar.dateComponents([.day, .weekOfYear, .month, .year, .weekday], from: date)

        guard let day = components.day, let month = components.month, let weekday = components.weekday, let weekOfYear = components.weekOfYear, let dayOfYear = calendar.ordinality(of: .day, in: .year, for: date), let eventCreatedDate = eventCreatedDate else {
            return false
        }

        let dayString = dayOfWeekFromInteger(day: weekday)

        let weekNumberString = String(format: "%li", weekOfYear)
        let monthString = String(format: "%li", month)

        // If the event is set to repeat on a certain day of the week, it MUST be the current date's weekday for it to occur
        if let exRuleByDay = exRuleByDay, !exRuleByDay.contains(dayString) {
            // These checks are to catch if the event is set to repeat on a particular weekday of the month (e.g., every third Sunday)
            if !exRuleByDay.contains(String(format: "1%@", dayString)), !exRuleByDay.contains(String(format: "2%@", dayString)), !exRuleByDay.contains(String(format: "3%@", dayString)) {
                return false
            }
        }

        // Same as above (and bellow)
        if let exRuleByMonthDay = exRuleByMonthDay, !exRuleByMonthDay.contains(String(format: "%li", day)) {
            return false
        }

        if let exRuleByYearDay = exRuleByYearDay, !exRuleByYearDay.contains(String(format: "%li", dayOfYear)) {
            return false
        }

        if let exRuleByWeekNo = exRuleByWeekNo, !exRuleByWeekNo.contains(weekNumberString) {
            return false
        }

        if let exRuleByMonth = exRuleByMonth, !exRuleByMonth.contains(monthString) {
            return false
        }

        exRuleInterval = exRuleInterval ?? "1"

        guard let exRuleInterval = exRuleInterval, let exRuleIntervalInt = Int(exRuleInterval), let eventEndDate = eventEndDate else {
            return false
        }

        // If it's set to repeat every week...
        if exRuleFrequency == WEEKLY_FREQUENCY {
            // Is there a limit on the number of repetitions
            // (e.g., event repeats for the 3 occurrences after it first occurred)
            if let exRuleCount = exRuleCount, let exRuleCountInt = Int(exRuleCount) {
                // Get the final possible time the event will be repeated
                var comp = DateComponents()
                comp.day = exRuleCountInt * exRuleIntervalInt

                // Create a date by adding the final week it'll occur onto the first occurrence
                guard let maximumDate = calendar.date(byAdding: comp, to: eventEndDate) else {
                    return false
                }

                // If the final possible occurrence is in the future...
                if maximumDate.compare(date) == .orderedDescending || maximumDate.compare(date) == .orderedSame {
                    // Get the number of weeks between the final date and current date

                    if let difference = calendar.dateComponents([.day], from: maximumDate, to: date).day {
                        if difference % exRuleIntervalInt != 0 {
                            return false
                        } else {
                            return true
                        }
                    }
                } else {
                    return false
                }
            } else if let exRuleUntilDate = exRuleUntilDate {
                if exRuleUntilDate.compare(date) == .orderedDescending || exRuleUntilDate.compare(date) == .orderedSame, let difference = calendar.dateComponents([.day], from: exRuleUntilDate, to: date).day {
                    if difference % exRuleIntervalInt != 0 {
                        return false
                    } else {
                        return true
                    }
                } else {
                    return false
                }
            } else if let difference = calendar.dateComponents([.day], from: eventCreatedDate, to: date).day {
                if difference % exRuleIntervalInt != 0 {
                    return false
                } else {
                    return true
                }
            }
        } else if exRuleFrequency == MONTHLY_FREQUENCY {
            if let exRuleCount = exRuleCount, let exRuleCountInt = Int(exRuleCount) {
                let finalMonth = exRuleCountInt * exRuleIntervalInt

                var comp = DateComponents()
                comp.month = finalMonth

                let maximumDate = calendar.date(byAdding: comp, to: eventEndDate)
                if maximumDate?.compare(date) == .orderedDescending || maximumDate?.compare(date) == .orderedSame, let calendarDate = calendar.date(from: comp), let difference = calendar.dateComponents([.month], from: calendarDate, to: date).month {
                    if difference % exRuleIntervalInt != 0 {
                        return false
                    } else {
                        return true
                    }
                } else {
                    return false
                }
            } else if let exRuleUntilDate = exRuleUntilDate {
                if exRuleUntilDate.compare(date) == .orderedDescending || exRuleUntilDate.compare(date) == .orderedSame, let difference = calendar.dateComponents([.month], from: exRuleUntilDate, to: date).month {
                    if difference % exRuleIntervalInt != 0 {
                        return false
                    } else {
                        return true
                    }
                } else {
                    return false
                }
            } else {
                if let difference = calendar.dateComponents([.day], from: eventCreatedDate, to: date).month, difference % exRuleIntervalInt != 0 {
                    return false
                } else {
                    return true
                }
            }
        } else if exRuleFrequency == YEARLY_FREQUENCY {
            if let exRuleCount = exRuleCount, let exRuleCountInt = Int(exRuleCount) {
                let finalYear = exRuleCountInt * exRuleIntervalInt
                var comp = DateComponents()
                comp.year = finalYear

                let maximumDate = calendar.date(byAdding: comp, to: eventEndDate)

                if maximumDate?.compare(date) == .orderedDescending || maximumDate?.compare(date) == .orderedSame, let calendarDate = calendar.date(from: comp), let difference = calendar.dateComponents([.year], from:calendarDate, to: date).year {
                    if difference % exRuleIntervalInt != 0 {
                        return false
                    } else {
                        return true
                    }
                }
            } else if let exRuleUntilDate = exRuleUntilDate, let difference = calendar.dateComponents([.year], from: exRuleUntilDate, to: date).year {
                if difference % exRuleIntervalInt != 0 {
                    return false
                } else {
                    return true
                }
            } else {
                if let difference = calendar.dateComponents([.year], from: eventCreatedDate, to: date).year {
                    if difference % exRuleIntervalInt != 0 {
                        return false
                    } else {
                        return true
                    }
                }
            }
        } else {
            return false
        }

        return false
    }
    
    /// Converts the event to an `EKEvent` for a specific date.
    /// - Parameters:
    ///   - date: The date for which to create the `EKEvent`.
    ///   - eventStore: The event store used to create the `EKEvent`.
    /// - Returns: An `EKEvent` if conversion is successful; otherwise, `nil`.
    public func convertToEKEventOn(date: Date, store eventStore: EKEventStore) -> EKEvent? {
        guard let eventStartDate = eventStartDate, let eventEndDate = eventEndDate, let eventSummary = eventSummary, let eventIsAllDay = eventIsAllDay else {
            return nil
        }
        var components = Calendar.current.dateComponents([.hour, .minute, .day, .month, .year], from: eventStartDate)
        var endComponents = Calendar.current.dateComponents([.hour, .minute, .day, .month, .year], from: eventEndDate)
        let selectedDayComponents = Calendar.current.dateComponents([.day, .month, .year], from: date)

        components.day = selectedDayComponents.day
        components.month = selectedDayComponents.month
        components.year = selectedDayComponents.year

        endComponents.day = selectedDayComponents.day
        endComponents.month = selectedDayComponents.month
        endComponents.year = selectedDayComponents.year

        let event = EKEvent(eventStore: eventStore)
        event.title = eventSummary
        event.notes = eventDescription
        event.location = eventLocation
        event.isAllDay = eventIsAllDay

        event.startDate = Calendar.current.date(from: components) ?? Date()
        event.endDate = Calendar.current.date(from: endComponents) ?? Date()

        return event
    }
    
    /// Checks if a specific time falls within the event's duration.
    /// - Parameter targetTime: The time to check.
    /// - Returns: `true` if the target time is within the event's duration; otherwise, `false`.
    public func checkTime(targetTime: Date) -> Bool {
        guard let firstStartTime = eventStartDate, let firstEndTime = eventEndDate else { return false }
        
        if repeatRuleFrequency == nil {
            return dateWithinRange(date: targetTime, start: firstStartTime, end: firstEndTime)
        } else {
            guard let calendar = calendar else {
                return false
            }
            
            // check if there's an occurrence that starts on the same day as targetTime
            if checkDate(date: targetTime) {

                // now check if targetTime is actually inside that occurrence
                
                // number of years, months, days, between firstStart's date and targetTimes's date
                let daysSinceFirstStart = calendar.dateComponents([.year, .month, .day], from: firstStartTime, to: targetTime)
                // add to firstStart and firstEnd the computed number of years, months, days, to get start and end times of the target occurrence
                if let targetStartTime = calendar.date(byAdding: daysSinceFirstStart, to: firstStartTime),
                    let targetEndTime = calendar.date(byAdding: daysSinceFirstStart, to: firstEndTime),
                    dateWithinRange(date: targetTime, start: targetStartTime, end: targetEndTime) {
                    
                    return true
                }
            } else {
                // check if there's an occurrence that starts the day before targetTime.
                let startOfTargetDay = calendar.startOfDay(for: targetTime)
                let nightBeforeTargetTime = startOfTargetDay.addingTimeInterval(-1)
                if checkDate(date: nightBeforeTargetTime) {
                    // now check if targetTime is actually inside that occurrence, this time by using number of years, months, days, since firstEnd's date
                    let daysSinceFirstEnd = calendar.dateComponents([.year, .month, .day], from: firstEndTime, to: targetTime)
                    if let targetStartTime = calendar.date(byAdding: daysSinceFirstEnd, to: firstStartTime),
                        let targetEndTime = calendar.date(byAdding: daysSinceFirstEnd, to: firstEndTime),
                        dateWithinRange(date: targetTime, start: targetStartTime, end: targetEndTime),
                        dateWithinRange(date: nightBeforeTargetTime, start: targetStartTime, end: targetEndTime) {
                        
                        return true
                    }
                }
            }
            
            // KNOWN LIMITATION: this only works for events that span across at most 2 days
            return false
        }
    }

    /// Determines if a given date falls within a specified range.
    /// - Parameters:
    ///   - date: The date to check.
    ///   - start: The start date of the range.
    ///   - end: The end date of the range.
    /// - Returns: `true` if the date falls within the range; otherwise, `false`.
    private func dateWithinRange(date: Date, start: Date, end: Date) -> Bool {
        guard start < end else { return false }
        
        let range = start ... end
        return range.contains(date)
    }
    
    /// Converts an integer representing a day of the week to its string abbreviation.
    /// - Parameter day: The integer representing the day of the week.
    /// - Returns: A string abbreviation of the day of the week.
    private func dayOfWeekFromInteger(day: Int) -> String {
        switch day {
        case 1:
            return "SU"
        case 2:
            return "MO"
        case 3:
            return "TU"
        case 4:
            return "WE"
        case 5:
            return "TH"
        case 6:
            return "FR"
        case 7:
            return "SA"
        default:
            return ""
        }
    }
}

// MARK: - Equatable Extension

func ==<T: Equatable>(lhs: [T]?, rhs: [T]?) -> Bool {
    switch (lhs, rhs) {
    case (.some(let lhs), .some(let rhs)):
        return lhs == rhs
    case (.none, .none):
        return true
    default:
        return false
    }
}

extension MXLCalendarEvent: Equatable {
    public static func == (lhs: MXLCalendarEvent, rhs: MXLCalendarEvent) -> Bool {
        let exRuleCheck = lhs.exRuleCount == rhs.exRuleCount &&
            lhs.exRuleRuleWkSt == rhs.exRuleRuleWkSt &&
            lhs.exRuleInterval == rhs.exRuleInterval &&
            lhs.exRuleWeekStart == rhs.exRuleWeekStart &&
            lhs.exRuleUntilDate == rhs.exRuleUntilDate &&
            lhs.exRuleBySecond == rhs.exRuleBySecond &&
            lhs.exRuleByMinute == rhs.exRuleByMinute &&
            lhs.exRuleByHour == rhs.exRuleByHour &&
            lhs.exRuleByDay == rhs.exRuleByDay &&
            lhs.exRuleByMonthDay == rhs.exRuleByMonthDay &&
            lhs.exRuleByYearDay == rhs.exRuleByYearDay &&
            lhs.exRuleByWeekNo == rhs.exRuleByWeekNo &&
            lhs.exRuleByMonth == rhs.exRuleByMonth &&
            lhs.exRuleBySetPos == rhs.exRuleBySetPos
        
        let repeatRuleCheck = lhs.repeatRuleFrequency == rhs.repeatRuleFrequency &&
            lhs.repeatRuleCount == rhs.repeatRuleCount &&
            lhs.repeatRuleRuleWkSt == rhs.repeatRuleRuleWkSt &&
            lhs.repeatRuleInterval == rhs.repeatRuleInterval &&
            lhs.repeatRuleWeekStart == rhs.repeatRuleWeekStart &&
            lhs.repeatRuleUntilDate == rhs.repeatRuleUntilDate &&
            lhs.repeatRuleBySecond == rhs.repeatRuleBySecond &&
            lhs.repeatRuleByMinute == rhs.repeatRuleByMinute &&
            lhs.repeatRuleByHour == rhs.repeatRuleByHour &&
            lhs.repeatRuleByDay == rhs.repeatRuleByDay &&
            lhs.repeatRuleByMonthDay == rhs.repeatRuleByMonthDay &&
            lhs.repeatRuleByYearDay == rhs.repeatRuleByYearDay &&
            lhs.repeatRuleByWeekNo == rhs.repeatRuleByWeekNo &&
            lhs.repeatRuleByMonth == rhs.repeatRuleByMonth &&
            lhs.repeatRuleBySetPos == rhs.repeatRuleBySetPos
        
        let eventCheck = lhs.dateFormatter == rhs.dateFormatter &&
            lhs.calendar == rhs.calendar &&
            lhs.eventStartDate == rhs.eventStartDate &&
            lhs.eventEndDate == rhs.eventEndDate &&
            lhs.eventCreatedDate == rhs.eventCreatedDate &&
            lhs.eventLastModifiedDate == rhs.eventLastModifiedDate &&
            lhs.eventIsAllDay == rhs.eventIsAllDay &&
            lhs.eventUniqueID == rhs.eventUniqueID &&
            lhs.eventRecurrenceID == rhs.eventRecurrenceID &&
            lhs.eventSummary == rhs.eventSummary &&
            lhs.eventDescription == rhs.eventDescription &&
            lhs.eventLocation == rhs.eventStatus &&
            lhs.attendees == rhs.attendees &&
            lhs.rruleString == rhs.rruleString
        
        return exRuleCheck && repeatRuleCheck && eventCheck
    }
}
