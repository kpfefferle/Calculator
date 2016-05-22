//
//  ViewController.swift
//  Calculator
//
//  Created by Kevin Pfefferle on 5/22/16.
//  Copyright © 2016 Kevin Pfefferle. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var display: UILabel!
    
    var userIsTyping = false

    @IBAction func touchDigit(sender: UIButton) {
        if let digit = sender.currentTitle,
          let currentDisplay = display.text {
            if userIsTyping {
                display.text = currentDisplay + digit
            } else {
                display.text = digit
            }
            userIsTyping = true
        }
    }

}

