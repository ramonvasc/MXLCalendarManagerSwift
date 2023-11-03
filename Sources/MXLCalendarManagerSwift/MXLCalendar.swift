//
//  MXLCalendar.swift
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

public class MXLCalendar {
    public var daysOfEvents = [String: [MXLCalendarEvent]]()
    public var loadedEvents = [String: Bool]()

    public var calendar: Calendar?

    public var timeZone: TimeZone?
    public var events = [MXLCalendarEvent]()

    public init() {}

    public func add(event: MXLCalendarEvent) {
        events.append(event)
    }

    public func add(event: MXLCalendarEvent, onDay day: Int, month: Int, year: Int) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyddMM"

        var components = Calendar.current.dateComponents([.day, .month, .year], from: Date())
        components.day = day
        components.month = month
        components.year = year

        guard let calendarDate = Calendar.current.date(from: components) else {
            return
        }
        add(event: event, onDate: formatter.string(from: calendarDate))
    }

    public func add(event: MXLCalendarEvent, onDate date: String) {
        // Check if the event has already been logged today
        guard var dateDaysOfEvents = daysOfEvents[date] else {
            // If there are no current dates on today, create a new array and save it for the day
            daysOfEvents[date] = [event]
            return
        }
        for currentEvent in dateDaysOfEvents {
            if currentEvent.eventUniqueID == event.eventUniqueID {
                return
            }
        }

        // If there are already events for this date...
        if dateDaysOfEvents.contains(event) {
            return
        } else {
            // If not, add it to the day
            dateDaysOfEvents.append(event)
            daysOfEvents[date] = dateDaysOfEvents
        }
    }

    public func add(event: MXLCalendarEvent, onDate date: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyddMM"

        add(event: event, onDate: dateFormatter.string(from: date))
    }

    public func loadedAllEventsForDate(date: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyddMM"
        loadedEvents[dateFormatter.string(from: date)] = NSNumber(value: true).boolValue
    }

    public func hasLoadedAllEventsFor(date: Date) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyddMM"
        let dateString = dateFormatter.string(from: date)
        if let loadedEvents = loadedEvents[dateString], loadedEvents {
            return true
        }
        return false
    }

    public func eventsFor(date: Date) -> [MXLCalendarEvent]? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyddMM"

        if let dateDaysOfEvents = daysOfEvents[dateFormatter.string(from: date)] {
            let sortedArray = (dateDaysOfEvents as NSArray).sortedArray(options: .concurrent) { (firstEvent, secondEvent) -> ComparisonResult in
                guard let firstEvent = firstEvent as? MXLCalendarEvent, let secondEvent = secondEvent as? MXLCalendarEvent, let firstEventStartDate = firstEvent.eventStartDate, let secondEventStartDate = secondEvent.eventStartDate else {
                    return ComparisonResult.orderedSame
                }
                let firstDateComponents = Calendar.current.dateComponents([.hour, .minute, .second], from: firstEventStartDate)
                let secondDateComponents = Calendar.current.dateComponents([.hour, .minute, .second], from: secondEventStartDate)

                guard let firstDate = Calendar.current.date(from: firstDateComponents), let secondDate = Calendar.current.date(from: secondDateComponents) else {
                    return ComparisonResult.orderedSame
                }
                return firstDate.compare(secondDate)
            } as? [MXLCalendarEvent]
            daysOfEvents[dateFormatter.string(from: date)] = sortedArray
        }
        return daysOfEvents[dateFormatter.string(from: date)]
    }
}

public extension MXLCalendar {
    func containsEvent(at time: Date) -> Bool {
        return events.contains(where: { (event: MXLCalendarEvent) -> Bool in
            return event.checkTime(targetTime: time)
        })
    }
}
