## MXLCalendarManagerSwift
A set of classes to parse and handle iCalendar (.ICS) files. The framework can parse through an iCalendar file and extract all VEVENT objects into MXLCalendarEvent items. Then, by running the [checkDate:](https://github.com/ramonvasc/MXLCalendarManagerSwift/blob/c4cf1f27845172189f568100f907e4e7eecaa015/MXLCalendarManagerSwift/MXLCalendarEvent.swift#L351) or [checkDay:month:year](https://github.com/ramonvasc/MXLCalendarManagerSwift/blob/c4cf1f27845172189f568100f907e4e7eecaa015/MXLCalendarManagerSwift/MXLCalendarEvent.swift#L339) you can see if the event occurs on a certain day.

## Usage

### Quick Start

```swift
import MXLCalendarManagerSwift

class MyViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let filePath = Bundle.main.path(forResource: "basic", ofType: "ics") else {
            return
        }
        let calendarManager = MXLCalendarManager()
        calendarManager.scanICSFileatLocalPath(filePath: filePath) { (calendar, error) in
            guard let calendar = calendar else {
                return
            }
            print(calendar)
        }
    }

}
```

## Installation

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ brew install cocoapods
```

> CocoaPods 1.10.0+ is required to build MXLCalendarManagerSwift.

To integrate MXLCalendarManagerSwift into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '13.0'
use_frameworks!

target '<Your Target Name>' do
    pod 'MXLCalendarManagerSwift'
end
```

Then, run the following command:

```bash
$ pod install
```


### Swift Package Manager

[Swift Package Manager](https://swift.org/package-manager/) is a tool for managing the distribution of Swift code. It’s integrated with the Swift build system to automate the process of downloading, compiling, and linking dependencies.

> Xcode 12+ is required to build MXLCalendarManagerSwift using Swift Package Manager.

To integrate MXLCalendarManagerSwift into your Xcode project using Swift Package Manager, add it to the dependencies value of your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/ramonvasc/MXLCalendarManagerSwift", .upToNextMajor(from: "1.0.10"))
]
```

### Manually

If you prefer not to use either of the aforementioned dependency managers, you can integrate MXLCalendarManagerSwift into your project manually.

---

## Credits

- Swift version of the MXLCalendarManager (https://github.com/KiranPanesar/MXLCalendarManager)

## License

MXLCalendarManagerSwift is released under the MIT license. See LICENSE for details.