//
//  ViewController.swift
//  Calculator
//
//  Created by Kevin Pfefferle on 5/22/16.
//  Copyright © 2016 Kevin Pfefferle. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBAction func touchDigit(sender: UIButton) {
        if let digit = sender.currentTitle {
            NSLog("touchDigit #\(digit)")
        }
    }

}

