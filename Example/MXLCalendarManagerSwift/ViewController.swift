//
//  ViewController.swift
//  MXLCalendarManagerSwift
//
//  Created by Ramon Vasconcelos on 08/22/2017.
//  Copyright (c) 2017 Ramon Vasconcelos. All rights reserved.
//

import UIKit
import MXLCalendarManagerSwift

class ViewController: UIViewController {

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

