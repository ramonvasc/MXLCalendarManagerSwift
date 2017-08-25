//
//  TimeZone+ProperAbbreviation.swift
//  Pods
//
//  Created by Ramon Vasconcelos on 25/08/2017.
//
//

import Foundation

extension TimeZone {
    var properAbbreviation: String? {
        if abbreviation() == "GMT" || abbreviation() == "BST" {
            return abbreviation()
        }

        let timezoneNames = TimeZone.knownTimeZoneIdentifiers

        for name in timezoneNames.sorted() {
            print(name)
        }

        let abbrev = TimeZone.abbreviationDictionary
        return abbrev.allKeys(forValue: self.identifier).first
    }
}

extension Dictionary where Value: Equatable {
    func allKeys(forValue val: Value) -> [Key] {
        return self.filter { $1 == val }.map { $0.0 }
    }
}
