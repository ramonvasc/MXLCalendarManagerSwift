//
//  MXLCalendarAttendee.swift
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

public enum Role: String {
    case CHAIR = "CHAIR"
    case REQ_PARTICIPANT = "REQ-PARTICIPANT"
    case OPT_PARTICIPANT = "OPT-PARTICIPANT"
    case NON_PARTICIPANT = "NON-PARTICIPANT"
}

public enum PartStat: String {
    case TENTATIVE = "TENTATIVE"
    case ACCEPTED = "ACCEPTED"
    case NEEDS_ACTION = "NEEDS-ACTION"
    case DECLINED = "DECLINED"
    case DELEGATED = "DELEGATED"
    case COMPLETED = "COMPLETED"
    case IN_PROCESS = "IN-PROCESS"
}

public struct MXLCalendarAttendee: Equatable {
    public let uri: String
    public let commonName: String
    public let role: Role
    public let participantStatus: PartStat

    public init(withRole role: Role, commonName: String, andUri uri: String, participantStatus: PartStat) {
        self.uri = uri
        self.commonName = commonName
        self.role = role
        self.participantStatus = participantStatus
    }
}
