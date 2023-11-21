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

/// Represents a calendar with its events and their management functionalities.
public class MXLCalendar {
    // Dictionary to store events keyed by their date strings.
    public var daysOfEvents = [String: [MXLCalendarEvent]]()

    // Tracks whether all events for a particular date have been loaded.
    public var loadedEvents = [String: Bool]()

    // Optional properties for calendar and time zone.
    public var calendar: Calendar?
    public var timeZone: TimeZone?

    // Use synchronization mechanisms such as locks to ensure that only one
    // thread can access the events array at a time.
    private let eventQueue = DispatchQueue(label: "com.mxlcalendar.eventQueue", attributes: .concurrent)
    private var _events = [MXLCalendarEvent]()
    
    // Computed property to safely access events
    public var events: [MXLCalendarEvent] {
        get {
            return eventQueue.sync {
                _events
            }
        }
        set {
            eventQueue.async(flags: .barrier) {
                self._events = newValue
            }
        }
    }

    // DateFormatter initialized for consistent date format usage.
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        return formatter
    }()

    /// Initializes a new instance of MXLCalendar.
    public init() {}

    /// Adds an event to the general list of events.
    /// - Parameter event: The `MXLCalendarEvent` to be added.
    public func add(event: MXLCalendarEvent) {
        events.append(event)
    }

    /// Adds an event for a specific day, month, and year.
    /// - Parameters:
    ///   - event: The `MXLCalendarEvent` to be added.
    ///   - day: The day of the event.
    ///   - month: The month of the event.
    ///   - year: The year of the event.
    public func add(event: MXLCalendarEvent, onDay day: Int, month: Int, year: Int) {
        var components = DateComponents()
        components.day = day
        components.month = month
        components.year = year

        if let calendarDate = Calendar.current.date(from: components) {
            add(event: event, onDate: calendarDate)
        }
    }

    /// Adds an event for a specific date.
    /// - Parameters:
    ///   - event: The `MXLCalendarEvent` to be added.
    ///   - date: The date for the event.
    public func add(event: MXLCalendarEvent, onDate date: Date) {
        let dateString = dateFormatter.string(from: date)
        add(event: event, onDateString: dateString)
    }

    /// Private method for adding an event using a date string.
    /// - Parameters:
    ///   - event: The `MXLCalendarEvent` to be added.
    ///   - dateString: The date string representing the date of the event.
    private func add(event: MXLCalendarEvent, onDateString dateString: String) {
        var eventsForDate = daysOfEvents[dateString, default: []]
        if !eventsForDate.contains(where: { $0.eventUniqueID == event.eventUniqueID }) {
            eventsForDate.append(event)
            daysOfEvents[dateString] = eventsForDate
        }
    }

    /// Marks all events for a given date as loaded.
    /// - Parameter date: The date for which events have been loaded.
    public func loadedAllEventsForDate(date: Date) {
        loadedEvents[dateFormatter.string(from: date)] = true
    }
    
    /// Checks if all events for a given date have been loaded.
    /// - Parameter date: The date to check for loaded events.
    /// - Returns: `true` if all events for the date have been loaded; otherwise, `false`.
    public func hasLoadedAllEventsFor(date: Date) -> Bool {
        loadedEvents[dateFormatter.string(from: date)] ?? false
    }

    /// Returns all events for a given date, sorted by start time.
    /// - Parameter date: The date for which to retrieve events.
    /// - Returns: An array of `MXLCalendarEvent` for the given date, sorted by start time.
    public func eventsFor(date: Date) -> [MXLCalendarEvent]? {
        let dateString = dateFormatter.string(from: date)
        
        // Sorts the events based on their start date, handling optional dates safely.
        return daysOfEvents[dateString]?.sorted(by: { (firstEvent, secondEvent) -> Bool in
            switch (firstEvent.eventStartDate, secondEvent.eventStartDate) {
            case let (firstDate?, secondDate?):
                return firstDate < secondDate
            case (nil, _):
                return true // First event has no start date, so it comes first.
            case (_, nil):
                return false // Second event has no start date, so it comes second.
            }
        })
    }
}

public extension MXLCalendar {
    /// Checks if there is an event occurring at a given time.
    /// - Parameter time: The time to check for an event's occurrence.
    /// - Returns: `true` if there is an event occurring at the given time; otherwise, `false`.
    func containsEvent(at time: Date) -> Bool {
        events.contains { $0.checkTime(targetTime: time) }
    }
}
