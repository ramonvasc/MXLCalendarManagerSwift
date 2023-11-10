import XCTest
@testable import MXLCalendarManagerSwift

final class MXLCalendarManagerTests: XCTestCase {
    private let manager = MXLCalendarManager()
    private var parsedCalendar: MXLCalendar!
    private let dateFormatter = DateFormatter()

    override func setUp() {
        super.setUp()

        dateFormatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
    }

    func parseCalendarWithEvent(eventString: String) {
        let calendarString =
            """
BEGIN:VCALENDAR
PRODID:-//Google Inc//Google Calendar 70.9054//EN
VERSION:2.0
CALSCALE:GREGORIAN
METHOD:PUBLISH
X-WR-CALNAME:foo@gmail.com
X-WR-TIMEZONE:Atlantic/Reykjavik
BEGIN:VTIMEZONE
TZID:America/Los_Angeles
X-LIC-LOCATION:America/Los_Angeles
BEGIN:DAYLIGHT
TZOFFSETFROM:-0800
TZOFFSETTO:-0700
TZNAME:PDT
DTSTART:19700308T020000
RRULE:FREQ=YEARLY;BYMONTH=3;BYDAY=2SU
END:DAYLIGHT
BEGIN:STANDARD
TZOFFSETFROM:-0700
TZOFFSETTO:-0800
TZNAME:PST
DTSTART:19701101T020000
RRULE:FREQ=YEARLY;BYMONTH=11;BYDAY=1SU
END:STANDARD
END:VTIMEZONE
BEGIN:VTIMEZONE
TZID:Atlantic/Reykjavik
X-LIC-LOCATION:Atlantic/Reykjavik
BEGIN:STANDARD
TZOFFSETFROM:+0000
TZOFFSETTO:+0000
TZNAME:GMT
DTSTART:19700101T000000
END:STANDARD
END:VTIMEZONE
"""
                + eventString +
        """
        END:VCALENDAR
        """
        manager.parse(icsString: calendarString) { (calendar: MXLCalendar?, error: Error?) in
            XCTAssertNil(error)
            XCTAssert(calendar?.events.count ?? 0 > 0)
            self.parsedCalendar = calendar
        }
    }

    // MARK: - Daily Tests

    func testSingleOccurrence() {
        let eventString = """
BEGIN:VEVENT
DTSTART:20181213T150000Z
DTEND:20181213T160000Z
DTSTAMP:20190619T173900Z
UID:69u21mqn7vq5gmph0r639gr6bh@google.com
CREATED:20190619T163823Z
DESCRIPTION:
LAST-MODIFIED:20190619T163823Z
LOCATION:
SEQUENCE:0
STATUS:CONFIRMED
SUMMARY:Single occurrence test
TRANSP:OPAQUE
END:VEVENT
"""
        parseCalendarWithEvent(eventString: eventString)
        let firstOccurrence = createDatePack(middle: "2018-12-13 15:11:52",
                                             begin: "2018-12-13 15:00:01",
                                             end: "2018-12-13 16:00:00",
                                             after: "2018-12-13 16:00:01")
        testHelper(trueOccurrences: [firstOccurrence],
                   falseOccurrences: [])
    }

    func testOnceDailyNoEndTest() {
        let eventString = """
BEGIN:VEVENT
DTSTART:20190617T010000Z
DTEND:20190617T020000Z
RRULE:FREQ=DAILY
DTSTAMP:20190619T173900Z
UID:29jct9nbfiod8bjo0umel2r5c6@google.com
CREATED:20190619T002440Z
DESCRIPTION:
LAST-MODIFIED:20190619T002440Z
LOCATION:
SEQUENCE:0
STATUS:CONFIRMED
SUMMARY:Every Day Event
TRANSP:OPAQUE
END:VEVENT
"""
        parseCalendarWithEvent(eventString: eventString)
        let occurrence = createDatePack(middle: "2020-06-17 01:11:52",
                                        begin: "2020-06-17 01:00:01",
                                        end: "2020-06-17 02:00:00",
                                        after: "2020-06-17 02:00:01")
        let nextOccurrence = createDatePack(middle: "2020-06-18 01:11:52",
                                            begin: "2020-06-18 01:00:01",
                                            end: "2020-06-18 02:00:00",
                                            after: "2020-06-18 02:00:01")

        testHelper(trueOccurrences: [occurrence, nextOccurrence],
                   falseOccurrences: [])
    }

    func testAllDayOnce() {
        let eventString = """
BEGIN:VEVENT
DTSTART;VALUE=DATE:20190406
DTEND;VALUE=DATE:20190407
DTSTAMP:20190619T173900Z
UID:2q0pu6s6nv38j0rh0qeeveuoki@google.com
CREATED:20190619T012159Z
DESCRIPTION:
LAST-MODIFIED:20190619T031600Z
LOCATION:
SEQUENCE:1
STATUS:CONFIRMED
SUMMARY:All Day Event
TRANSP:TRANSPARENT
END:VEVENT
"""
        parseCalendarWithEvent(eventString: eventString)
        let occurrence = createDatePack(middle: "2019-04-06 00:11:52",
                                        begin: "2019-04-06 00:00:01",
                                        end: "2019-04-07 00:00:00",
                                        after: "2019-04-07 00:00:01")
        testHelper(trueOccurrences: [occurrence],
                   falseOccurrences: [])
    }

    func testSpanDayOnce() {
        let eventString = """
BEGIN:VEVENT
DTSTART:20190401T000000Z
DTEND:20190402T120000Z
DTSTAMP:20190619T173900Z
UID:7a2q7llvsl8uvcaiv72s2ts2vl@google.com
CREATED:20190619T003248Z
DESCRIPTION:
LAST-MODIFIED:20190619T003248Z
LOCATION:
SEQUENCE:0
STATUS:CONFIRMED
SUMMARY:Multi Day Event
TRANSP:OPAQUE
END:VEVENT
"""
        parseCalendarWithEvent(eventString: eventString)
        let occurrence = createDatePack(middle: "2019-04-01 00:11:52",
                                        begin: "2019-04-01 00:00:01",
                                        end: "2019-04-02 12:00:00",
                                        after: "2019-04-02 12:00:01")
        testHelper(trueOccurrences: [occurrence],
                   falseOccurrences: [])

    }

    func testEveryOtherDayNoEnd() {
        let eventString = """
BEGIN:VEVENT
DTSTART;TZID=America/Los_Angeles:20190618T100000
DTEND;TZID=America/Los_Angeles:20190618T110000
RRULE:FREQ=DAILY;INTERVAL=2
DTSTAMP:20190619T173900Z
UID:7pochi1unhmcsqess0umdsfa5k@google.com
CREATED:20190617T160100Z
DESCRIPTION:
LAST-MODIFIED:20190617T160100Z
LOCATION:
SEQUENCE:0
STATUS:CONFIRMED
SUMMARY:Every Other Day Event
TRANSP:OPAQUE
END:VEVENT
"""
        parseCalendarWithEvent(eventString: eventString)
        let occurrence = createDatePack(middle: "2019-06-18 17:11:52",
                                        begin: "2019-06-18 17:00:01",
                                        end: "2019-06-18 18:00:00",
                                        after: "2019-06-18 18:00:01")
        let occurrence2 = createDatePack(middle: "2019-06-24 17:11:52",
                                         begin: "2019-06-24 17:00:01",
                                         end: "2019-06-24 18:00:00",
                                         after: "2019-06-24 18:00:01")
        let nonOccurrence = createDatePack(middle: "2019-06-19 17:11:52",
                                           begin: "2019-06-19 17:00:01",
                                           end: "2019-06-19 18:00:00",
                                           after: "2019-06-19 18:00:01")

        testHelper(trueOccurrences: [occurrence, occurrence2],
                   falseOccurrences: [nonOccurrence])
    }

    func testDailyThatFallsOffAfterDate() {
        let eventString = """
BEGIN:VEVENT
DTSTART:20190303T060000Z
DTEND:20190303T070000Z
RRULE:FREQ=DAILY;UNTIL=20190310
DTSTAMP:20190619T173900Z
UID:6skcrpc1qiad968i7afokdn12v@google.com
CREATED:20190619T012607Z
DESCRIPTION:
LAST-MODIFIED:20190619T012710Z
LOCATION:
SEQUENCE:0
STATUS:CONFIRMED
SUMMARY:Daily that falls off after a date
TRANSP:OPAQUE
END:VEVENT
"""
        parseCalendarWithEvent(eventString: eventString)
        let firstOccurrence = createDatePack(middle: "2019-03-03 06:11:52",
                                             begin: "2019-03-03 06:00:01",
                                             end: "2019-03-03 07:00:00",
                                             after: "2019-03-03 07:00:01")
        let lastOccurrence = createDatePack(middle: "2019-03-09 06:11:52",
                                            begin: "2019-03-09 06:00:01",
                                            end: "2019-03-09 07:00:00",
                                            after: "2019-03-09 07:00:01")
        let afterLastOccurrence = createDatePack(middle: "2019-03-10 06:11:52",
                                                 begin: "2019-03-10 06:00:01",
                                                 end: "2019-03-10 07:00:00",
                                                 after: "2019-03-10 07:00:01")

        testHelper(trueOccurrences: [firstOccurrence, lastOccurrence],
                   falseOccurrences: [afterLastOccurrence])
    }

    func testDailyThatFallsOffAfterThreeOccurrences() {
        let eventString = """
BEGIN:VEVENT
DTSTART:20190318T180000Z
DTEND:20190318T190000Z
RRULE:FREQ=DAILY;COUNT=3
DTSTAMP:20190619T173900Z
UID:1utcebtoh77dgi9o2075nteotd@google.com
CREATED:20190619T013032Z
DESCRIPTION:
LAST-MODIFIED:20190619T013102Z
LOCATION:
SEQUENCE:1
STATUS:CONFIRMED
SUMMARY:Daily Event That falls off after 3 times
TRANSP:OPAQUE
END:VEVENT
"""
        parseCalendarWithEvent(eventString: eventString)
        let firstOccurrence = createDatePack(middle: "2019-03-18 18:11:52",
                                             begin: "2019-03-18 18:00:00",
                                             end: "2019-03-18 19:00:00",
                                             after: "2019-03-18 19:00:01")
        let lastOccurrence = createDatePack(middle: "2019-03-20 18:11:52",
                                            begin: "2019-03-20 18:00:00",
                                            end: "2019-03-20 19:00:00",
                                            after: "2019-03-20 19:00:01")
        let afterLastOccurrence = createDatePack(middle: "2019-03-21 18:11:52",
                                                 begin: "2019-03-21 18:00:00",
                                                 end: "2019-03-21 19:00:00",
                                                 after: "2019-03-21 19:00:01")

        testHelper(trueOccurrences: [firstOccurrence, lastOccurrence],
                   falseOccurrences: [afterLastOccurrence])
    }

    func testDailySpanWithABreak() {
        let eventString = """
BEGIN:VEVENT
DTSTART:20180708T150000Z
DTEND:20180708T160000Z
RRULE:FREQ=DAILY;UNTIL=20180807
EXDATE:20180712T150000Z
DTSTAMP:20190619T173900Z
UID:3dhuorkt40h1oqgb7f76mupkjo@google.com
CREATED:20190619T165437Z
DESCRIPTION:
LAST-MODIFIED:20190619T165437Z
LOCATION:
SEQUENCE:0
STATUS:CONFIRMED
SUMMARY:Daily Span With Break
TRANSP:OPAQUE
END:VEVENT
"""
        parseCalendarWithEvent(eventString: eventString)
        let firstOccurrence = createDatePack(middle: "2018-07-08 15:11:52",
                                             begin: "2018-07-08 15:00:52",
                                             end: "2018-07-08 15:59:59",
                                             after: "2018-07-08 16:00:01")
        let lastOccurrence = createDatePack(middle: "2018-08-06 15:11:52",
                                            begin: "2018-08-06 15:00:52",
                                            end: "2018-08-06 15:59:59",
                                            after: "2018-08-06 16:00:01")
        let breakOccurrence = createDatePack(middle: "2018-07-12 15:11:52",
                                             begin: "2018-07-12 15:00:52",
                                             end: "2018-07-12 15:59:59",
                                             after: "2018-07-12 16:00:01")
        let afterLastOccurrence = createDatePack(middle: "2018-08-07 15:11:52",
                                                 begin: "2018-08-07 15:00:52",
                                                 end: "2018-08-07 15:59:59",
                                                 after: "2018-08-07 16:00:01")

        testHelper(trueOccurrences: [firstOccurrence, lastOccurrence],
                   falseOccurrences: [breakOccurrence, afterLastOccurrence])
    }

    // MARK: - Week Tests

    func testOnceWeeklyNoEnd() {
        let eventString = """
BEGIN:VEVENT
DTSTART;TZID=America/Los_Angeles:20190617T080000
DTEND;TZID=America/Los_Angeles:20190617T090000
RRULE:FREQ=WEEKLY;BYDAY=MO
DTSTAMP:20190619T173900Z
UID:0n6i6j8hk6j22tim9ark4jjd21@google.com
CREATED:20190617T142703Z
DESCRIPTION:
LAST-MODIFIED:20190617T142703Z
LOCATION:
SEQUENCE:0
STATUS:CONFIRMED
SUMMARY:Morning Monday 8PST recurrance
TRANSP:OPAQUE
END:VEVENT
"""
        parseCalendarWithEvent(eventString: eventString)
        let firstOccurrence = createDatePack(middle: "2019-06-17 15:11:52",
                                             begin: "2019-06-17 15:00:01",
                                             end: "2019-06-17 16:00:00",
                                             after: "2019-06-17 16:00:01")
        let nextOccurrence = createDatePack(middle: "2019-06-24 15:11:52",
                                            begin: "2019-06-24 15:00:01",
                                            end: "2019-06-24 16:00:00",
                                            after: "2019-04-05 16:00:01")

        testHelper(trueOccurrences: [firstOccurrence, nextOccurrence],
                   falseOccurrences: [])
    }

    func testOnceWeeklySpans2Days() {
        let eventString = """
BEGIN:VEVENT
DTSTART:20190322T230000Z
DTEND:20190323T010000Z
RRULE:FREQ=WEEKLY;WKST=SU;COUNT=3;BYDAY=FR
DTSTAMP:20190619T173900Z
UID:19msf7ro52aqcliviih9bqscdh@google.com
CREATED:20190619T021140Z
DESCRIPTION:
LAST-MODIFIED:20190619T021140Z
LOCATION:
SEQUENCE:0
STATUS:CONFIRMED
SUMMARY:Weekly Event That spans 2 days
TRANSP:OPAQUE
END:VEVENT
"""
        parseCalendarWithEvent(eventString: eventString)
        let firstOccurrence = createDatePack(middle: "2019-03-22 23:11:52",
                                             begin: "2019-03-22 23:00:00",
                                             end: "2019-03-23 01:00:00",
                                             after: "2019-03-23 01:00:01")
        let lastOccurrence = createDatePack(middle: "2019-04-05 23:11:52",
                                            begin: "2019-04-05 23:00:00",
                                            end: "2019-04-06 01:00:00",
                                            after: "2019-04-06 01:00:01")
        let afterLastOccurrence = createDatePack(middle: "2019-04-12 23:11:52",
                                                 begin: "2019-04-12 23:00:00",
                                                 end: "2019-04-13 01:00:00",
                                                 after: "2019-04-13 01:00:01")

        testHelper(trueOccurrences: [firstOccurrence, lastOccurrence],
                   falseOccurrences: [afterLastOccurrence])
    }

    func testOnceWeeklyThatFallsOffAfterThreeOccurances() {
        let eventString = """
BEGIN:VEVENT
DTSTART:20190322T150000Z
DTEND:20190322T160000Z
RRULE:FREQ=WEEKLY;WKST=SU;COUNT=3;BYDAY=FR
DTSTAMP:20190619T173900Z
UID:19msf7ro52aqcliviih9bqscdh@google.com
CREATED:20190619T021140Z
DESCRIPTION:
LAST-MODIFIED:20190619T021140Z
LOCATION:
SEQUENCE:0
STATUS:CONFIRMED
SUMMARY:Weekly Event That Falls Off after 3 times
TRANSP:OPAQUE
END:VEVENT
"""
        parseCalendarWithEvent(eventString: eventString)
        let firstOccurrence = createDatePack(middle: "2019-03-22 15:11:52",
                                             begin: "2019-03-22 15:00:00",
                                             end: "2019-03-22 16:00:00",
                                             after: "2019-03-22 16:00:01")
        let lastOccurrence = createDatePack(middle: "2019-04-05 15:11:52",
                                            begin: "2019-04-05 15:00:00",
                                            end: "2019-04-05 16:00:00",
                                            after: "2019-04-05 16:00:01")
        let afterLastOccurrence = createDatePack(middle: "2019-04-12 15:11:52",
                                                 begin: "2019-04-12 15:00:00",
                                                 end: "2019-04-12 16:00:00",
                                                 after: "2019-04-12 16:00:01")

        testHelper(trueOccurrences: [firstOccurrence, lastOccurrence],
                   falseOccurrences: [afterLastOccurrence])
    }

    func testOnceWeeklyThatFallsOffAfterDate() {
        let eventString = """
BEGIN:VEVENT
DTSTART:20190322T120000Z
DTEND:20190322T130000Z
RRULE:FREQ=WEEKLY;WKST=SU;UNTIL=20190330;BYDAY=FR
DTSTAMP:20190619T173900Z
UID:5ve6k1udshoh84p572dpbt64fr@google.com
CREATED:20190619T021304Z
DESCRIPTION:
LAST-MODIFIED:20190619T021304Z
LOCATION:
SEQUENCE:0
STATUS:CONFIRMED
SUMMARY:Weekly Event that falls off after a date
TRANSP:OPAQUE
END:VEVENT
"""
        parseCalendarWithEvent(eventString: eventString)
        let firstOccurrence = createDatePack(middle: "2019-03-22 12:11:52",
                                             begin: "2019-03-22 12:00:01",
                                             end: "2019-03-22 13:00:00",
                                             after: "2019-03-22 13:00:01")
        let nextOccurrence = createDatePack(middle: "2019-03-29 12:11:52",
                                            begin: "2019-03-29 12:00:01",
                                            end: "2019-03-29 13:00:00",
                                            after: "2019-03-29 13:00:01")
        let afterLastOccurrence = createDatePack(middle: "2019-04-05 12:11:52",
                                                 begin: "2019-04-05 12:00:01",
                                                 end: "2019-04-05 13:00:00",
                                                 after: "2019-04-05 13:00:01")
        let afterLastOccurrence2 = createDatePack(middle: "2019-04-12 12:11:52",
                                                  begin: "2019-04-12 12:00:01",
                                                  end: "2019-04-12 13:00:00",
                                                  after: "2019-04-12 13:00:01")

        testHelper(trueOccurrences: [firstOccurrence, nextOccurrence],
                   falseOccurrences: [afterLastOccurrence, afterLastOccurrence2])
    }

    func testWeeklySpanWithABreak() {
        let eventString = """
BEGIN:VEVENT
DTSTART:20170708T150000Z
DTEND:20170708T160000Z
RRULE:FREQ=WEEKLY;WKST=SU;UNTIL=20170909;BYDAY=SA
EXDATE:20170722T150000Z
DTSTAMP:20190619T173900Z
UID:4snjr7hro5c116nge7i4oq9o8h@google.com
CREATED:20190619T171652Z
DESCRIPTION:
LAST-MODIFIED:20190619T171652Z
LOCATION:
SEQUENCE:0
STATUS:CONFIRMED
SUMMARY:Weekly Event With Break
TRANSP:OPAQUE
END:VEVENT
"""
        parseCalendarWithEvent(eventString: eventString)
        let firstOccurrence = createDatePack(middle: "2017-07-08 15:11:52",
                                             begin: "2017-07-08 15:00:52",
                                             end: "2017-07-08 15:59:59",
                                             after: "2017-07-08 16:00:01")
        let lastOccurrence = createDatePack(middle: "2017-09-02 15:11:52",
                                            begin: "2017-09-02 15:00:01",
                                            end: "2017-09-02 15:59:59",
                                            after: "2017-09-02 16:00:01")
        let breakOccurrence = createDatePack(middle: "2017-07-22 15:11:52",
                                             begin: "2017-07-22 15:00:00",
                                             end: "2017-07-22 15:59:59",
                                             after: "2017-07-22 16:00:01")
        let afterLastOccurrence = createDatePack(middle: "2017-09-15 15:11:52",
                                                 begin: "2017-09-15 15:00:00",
                                                 end: "2017-09-15 15:59:59",
                                                 after: "2017-09-15 16:01:01")

        testHelper(trueOccurrences: [firstOccurrence, lastOccurrence],
                   falseOccurrences: [breakOccurrence, afterLastOccurrence])
    }

    // MARK - Month Tests

    func testOnceMonthlyNoEnd() {
        let eventString = """
BEGIN:VEVENT
DTSTART;TZID=America/Los_Angeles:20190619T210000
DTEND;TZID=America/Los_Angeles:20190620T080000
RRULE:FREQ=MONTHLY;BYMONTHDAY=19
DTSTAMP:20190619T173900Z
UID:0lf0j6g3tf4nok4llmm8lhbgq5@google.com
CREATED:20190617T161604Z
DESCRIPTION:
LAST-MODIFIED:20190617T161604Z
LOCATION:
SEQUENCE:0
STATUS:CONFIRMED
SUMMARY:Span days Monthly
TRANSP:OPAQUE
END:VEVENT
"""
        parseCalendarWithEvent(eventString: eventString)
        let firstOccurrence = createDatePack(middle: "2019-06-20 4:11:52",
                                             begin: "2019-06-20 4:00:01",
                                             end: "2019-06-20 15:00:00",
                                             after: "2019-06-20 15:00:01")
        let nextOccurrence = createDatePack(middle: "2019-07-20 4:11:52",
                                            begin: "2019-07-20 4:00:01",
                                            end: "2019-07-20 15:00:00",
                                            after: "2019-07-20 15:00:01")
        testHelper(trueOccurrences: [firstOccurrence, nextOccurrence],
                   falseOccurrences: [])
    }

    func testOnceMonthlyFallsOffAfterThreeTimes() {
        let eventString = """
BEGIN:VEVENT
DTSTART:20190103T010000Z
DTEND:20190103T020000Z
RRULE:FREQ=MONTHLY;COUNT=3;BYMONTHDAY=3
DTSTAMP:20190619T173900Z
UID:2vim0rkq97875do5uq7op3c24u@google.com
CREATED:20190619T022740Z
DESCRIPTION:
LAST-MODIFIED:20190619T022740Z
LOCATION:
SEQUENCE:0
STATUS:CONFIRMED
SUMMARY:Monthly Event Falls Off After 3 Times
TRANSP:OPAQUE
END:VEVENT
"""
        parseCalendarWithEvent(eventString: eventString)
        let firstOccurrence = createDatePack(middle: "2019-01-03 01:11:52",
                                             begin: "2019-01-03 01:00:52",
                                             end: "2019-01-03 02:00:00",
                                             after: "2019-01-03 02:00:01")
        let nextOccurrence = createDatePack(middle: "2019-02-03 01:11:52",
                                            begin: "2019-02-03 01:00:01",
                                            end: "2019-02-03 02:00:00",
                                            after: "2019-02-03 02:00:01")
        let lastOccurrence = createDatePack(middle: "2019-03-03 01:11:52",
                                            begin: "2019-03-03 01:00:01",
                                            end: "2019-03-03 02:00:00",
                                            after: "2019-03-03 02:00:01")
        let afterLastOccurrence = createDatePack(middle: "2019-04-03 01:11:52",
                                                 begin: "2019-04-03 01:00:01",
                                                 end: "2019-03-04 02:00:00",
                                                 after: "2019-04-03 02:00:01")

        testHelper(trueOccurrences: [firstOccurrence, nextOccurrence, lastOccurrence],
                   falseOccurrences: [afterLastOccurrence])
    }

    func testOnceMonthlyFallsOffAfterDate() {
        let eventString = """
BEGIN:VEVENT
DTSTART:20190103T150000Z
DTEND:20190103T160000Z
RRULE:FREQ=MONTHLY;COUNT=3;BYMONTHDAY=3
EXDATE:20190303T150000Z
DTSTAMP:20190619T173900Z
UID:79k24k77ub8kfhheqsc6vfg8k8@google.com
CREATED:20190619T024539Z
DESCRIPTION:
LAST-MODIFIED:20190619T024617Z
LOCATION:
SEQUENCE:1
STATUS:CONFIRMED
SUMMARY:Montly Event Falls Off After Feb 4
TRANSP:OPAQUE
END:VEVENT
"""
        parseCalendarWithEvent(eventString: eventString)
        let firstOccurrence = createDatePack(middle: "2019-01-03 15:11:52",
                                             begin: "2019-01-03 15:00:01",
                                             end: "2019-01-03 16:00:00",
                                             after: "2019-01-03 16:00:01")
        let lastOccurrence = createDatePack(middle: "2019-02-03 15:11:52",
                                            begin: "2019-02-03 15:00:01",
                                            end: "2019-02-03 16:00:00",
                                            after: "2019-02-03 16:00:01")
        let afterLastOccurrence = createDatePack(middle: "2019-03-03 15:11:52",
                                                 begin: "2019-03-03 15:00:01",
                                                 end: "2019-03-03 16:00:00",
                                                 after: "2019-03-03 16:00:01")

        testHelper(trueOccurrences: [firstOccurrence, lastOccurrence],
                   falseOccurrences: [afterLastOccurrence])
    }

    func testMonthlySpanWithBreak() {
        let eventString = """
BEGIN:VEVENT
DTSTART:20170108T160000Z
DTEND:20170108T170000Z
RRULE:FREQ=MONTHLY;COUNT=5;BYMONTHDAY=8
EXDATE:20170408T160000Z
DTSTAMP:20190619T173900Z
UID:42kb1udf7ti68km72fr7sotf76@google.com
CREATED:20190619T172058Z
DESCRIPTION:
LAST-MODIFIED:20190619T172058Z
LOCATION:
SEQUENCE:0
STATUS:CONFIRMED
SUMMARY:Monthly Span With Break
TRANSP:OPAQUE
END:VEVENT
END:VCALENDAR
"""
        parseCalendarWithEvent(eventString: eventString)
        let firstOccurrence = createDatePack(middle: "2017-01-08 16:11:52",
                                             begin: "2017-01-08 16:00:00",
                                             end: "2017-01-08 16:59:59",
                                             after: "2017-01-08 17:00:01")
        let lastOccurrence = createDatePack(middle: "2017-05-08 16:11:52",
                                            begin: "2017-05-08 16:00:00",
                                            end: "2017-05-08 16:59:59",
                                            after: "2017-06-08 16:00:01")
        let breakOccurrence = createDatePack(middle: "2017-04-08 16:11:52",
                                             begin: "2017-04-08 16:00:00",
                                             end: "2017-04-08 16:59:59",
                                             after: "2017-04-08 17:00:01")
        let afterLastOccurrence = createDatePack(middle: "2017-06-08 16:11:52",
                                                 begin: "2017-06-08 16:00:00",
                                                 end: "2017-06-08 16:59:59",
                                                 after: "2017-06-08 17:01:01")

        testHelper(trueOccurrences: [firstOccurrence, lastOccurrence],
                   falseOccurrences: [breakOccurrence, afterLastOccurrence])
    }

    // MARK - Year Tests

    func testOnceYearlyNoEnd() {
        let eventString = """
BEGIN:VEVENT
DTSTART;TZID=America/Los_Angeles:20191225T120000
DTEND;TZID=America/Los_Angeles:20191225T130000
RRULE:FREQ=YEARLY
DTSTAMP:20190619T173900Z
UID:4q6q03k2b32bfqca6mobcofpug@google.com
CREATED:20190617T161221Z
DESCRIPTION:
LAST-MODIFIED:20190619T003936Z
LOCATION:
SEQUENCE:2
STATUS:CONFIRMED
SUMMARY:Christmas event
TRANSP:TRANSPARENT
BEGIN:VALARM
ACTION:DISPLAY
DESCRIPTION:This is an event reminder
TRIGGER:-P0DT0H30M0S
END:VALARM
END:VEVENT
"""
        parseCalendarWithEvent(eventString: eventString)
        let occurrence = createDatePack(middle: "2021-12-25 20:11:52",
                                        begin: "2021-12-25 20:00:01",
                                        end: "2021-12-25 21:00:00",
                                        after: "2021-12-25 21:00:01")
        let occurrence2 = createDatePack(middle: "2022-12-25 20:11:52",
                                         begin: "2022-12-25 20:00:01",
                                         end: "2022-12-25 21:00:00",
                                         after: "2022-12-25 21:00:01")
        let farFuture = createDatePack(middle: "3022-12-25 20:11:52",
                                       begin: "3022-12-25 20:00:01",
                                       end: "3022-12-25 21:00:00",
                                       after: "3022-12-25 21:00:01")
        testHelper(trueOccurrences: [occurrence, occurrence2, farFuture],
                   falseOccurrences: [])
    }

    func testOnceYearlyFallsOffAfter2Times() {
        let eventString = """
BEGIN:VEVENT
DTSTART:20191224T200000Z
DTEND:20191224T210000Z
RRULE:FREQ=YEARLY;WKST=SU;COUNT=2
DTSTAMP:20190619T173900Z
UID:5mejtiseg020toknns83jbrjo3@google.com
CREATED:20190619T030415Z
DESCRIPTION:
LAST-MODIFIED:20190619T030415Z
LOCATION:
SEQUENCE:0
STATUS:CONFIRMED
SUMMARY:Christmas eve event drops off after 2 times
TRANSP:OPAQUE
END:VEVENT
"""
        parseCalendarWithEvent(eventString: eventString)
        let firstOccurrence = createDatePack(middle: "2019-12-24 20:11:52",
                                             begin: "2019-12-24 20:00:00",
                                             end: "2019-12-24 21:00:00",
                                             after: "2019-12-24 21:00:01")
        let lastOccurrence = createDatePack(middle: "2020-12-24 20:11:52",
                                            begin: "2020-12-24 20:00:00",
                                            end: "2020-12-24 21:00:00",
                                            after: "2020-12-24 21:00:01")
        let afterLastOccurrence = createDatePack(middle: "2021-12-24 20:11:52",
                                                 begin: "2021-12-24 20:00:00",
                                                 end: "2021-12-24 21:00:00",
                                                 after: "2021-12-24 21:00:01")

        testHelper(trueOccurrences: [firstOccurrence, lastOccurrence],
                   falseOccurrences: [afterLastOccurrence])
    }

    func testOnceYearlyFallsOffAfterDate() {
        let eventString = """
BEGIN:VEVENT
DTSTART:20191223T200000Z
DTEND:20191223T210000Z
RRULE:FREQ=YEARLY;UNTIL=20201224
DTSTAMP:20190619T173900Z
UID:2lqjkg6o8e9flh9meuf4siirr6@google.com
CREATED:20190619T030651Z
DESCRIPTION:
LAST-MODIFIED:20190619T030651Z
LOCATION:
SEQUENCE:0
STATUS:CONFIRMED
SUMMARY:Two days before chrismas drops off after 2020
TRANSP:OPAQUE
END:VEVENT
"""
        parseCalendarWithEvent(eventString: eventString)
        let firstOccurrence = createDatePack(middle: "2019-12-23 20:11:52",
                                             begin: "2019-12-23 20:00:01",
                                             end: "2019-12-23 21:00:00",
                                             after: "2019-12-23 21:00:01")
        let lastOccurrence = createDatePack(middle: "2020-12-23 20:11:52",
                                            begin: "2020-12-23 20:00:01",
                                            end: "2020-12-23 21:00:00",
                                            after: "2020-12-23 21:00:01")
        let afterLastOccurrence = createDatePack(middle: "2021-12-23 20:11:52",
                                                 begin: "2021-12-23 20:00:01",
                                                 end: "2021-12-23 21:00:00",
                                                 after: "2021-12-23 21:00:01")

        testHelper(trueOccurrences: [firstOccurrence, lastOccurrence],
                   falseOccurrences: [afterLastOccurrence])
    }
    
    func testDescriptionTagWithParameters() {
        let eventString = """
BEGIN:VEVENT
UID:2018101539720180906T132000
SUMMARY:15397 - 19th Century in Europe and Asia: Revolutions, Empires and Nations (the)
CATEGORIES:Cours magistral
DESCRIPTION;ENCODING=QUOTED-PRINTABLE:Enseignant(s) :\n - SCHEMPER Lukas :\n Enseignement :\n - AHIS 12A00 - 19th Century in Europe and Asia: Revolutions, Empires and Nations (the) - 201810
DTSTART;TZID=Europe/Paris:20180906T132000
DTEND;TZID=Europe/Paris:20180906T152000
LOCATION:Salle : GRAND AMPH - 77 rue Bellot - 76600 Le Havre
END:VEVENT
"""
        parseCalendarWithEvent(eventString: eventString)
        
        let expectedResult = "Enseignant(s) :- SCHEMPER Lukas :Enseignement :- AHIS 12A00 - 19th Century in Europe and Asia: Revolutions, Empires and Nations (the) - 201810"
        let eventDescription = parsedCalendar.events.first?.eventDescription
        XCTAssertNotNil(eventDescription)
        XCTAssertEqual(eventDescription, expectedResult)
    }

    // MARK - Helpers

    struct DatePack {
        let middle: Date!
        let begin: Date!
        let end: Date!
        let after: Date!
    }

    func createDatePack(middle: String, begin: String, end: String, after: String) -> DatePack {
        return DatePack(middle: dateFormatter.date(from: middle),
                        begin: dateFormatter.date(from: begin),
                        end: dateFormatter.date(from: end),
                        after: dateFormatter.date(from: after))
    }

    private func testHelper(trueOccurrences: [DatePack], falseOccurrences: [DatePack]) {
        for occurrence in trueOccurrences {
            // Test middle
            XCTAssert(parsedCalendar.containsEvent(at: occurrence.middle), String(describing: occurrence.middle))

            // Test boundaries
            XCTAssert(parsedCalendar.containsEvent(at: occurrence.begin), String(describing: occurrence.begin))
            XCTAssert(parsedCalendar.containsEvent(at: occurrence.end), String(describing: occurrence.end))
            XCTAssertFalse(parsedCalendar.containsEvent(at: occurrence.after), String(describing: occurrence.after))
        }

        for occurrence in falseOccurrences {
            XCTAssertFalse(parsedCalendar.containsEvent(at: occurrence.middle), String(describing: occurrence.middle))

            XCTAssertFalse(parsedCalendar.containsEvent(at: occurrence.begin), String(describing: occurrence.begin))
            XCTAssertFalse(parsedCalendar.containsEvent(at: occurrence.end), String(describing: occurrence.end))
            XCTAssertFalse(parsedCalendar.containsEvent(at: occurrence.after), String(describing: occurrence.after))
        }
    }
}
