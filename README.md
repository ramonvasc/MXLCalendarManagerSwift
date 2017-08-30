# MXLCalendarManagerSwift
Swift version of the MXLCalendarManager (https://github.com/KiranPanesar/MXLCalendarManager)

A set of classes to parse and handle iCalendar (.ICS) files. The framework can parse through an iCalendar file and extract all VEVENT objects into MXLCalendarEvent items. Then, by running the [checkDate:](https://github.com/ramonvasc/MXLCalendarManagerSwift/blob/c4cf1f27845172189f568100f907e4e7eecaa015/MXLCalendarManagerSwift/MXLCalendarEvent.swift#L351) or [checkDay:month:year](https://github.com/ramonvasc/MXLCalendarManagerSwift/blob/c4cf1f27845172189f568100f907e4e7eecaa015/MXLCalendarManagerSwift/MXLCalendarEvent.swift#L339) you can see if the event occurs on a certain day.

Installation
---
The recommended installation is via CocoaPods.

```
pod 'MXLCalendarManager'
```