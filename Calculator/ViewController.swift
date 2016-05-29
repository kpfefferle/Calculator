//
//  ViewController.swift
//  Calculator
//
//  Created by Kevin Pfefferle on 5/22/16.
//  Copyright © 2016 Kevin Pfefferle. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet private weak var display: UILabel!
    @IBOutlet private weak var descriptionDisplay: UILabel!
    
    private var userIsTyping = false

    @IBAction private func touchDigit(sender: UIButton) {
        if let digit = sender.currentTitle,
          let currentDisplay = display.text {
            if digit == "." && currentDisplay.rangeOfString(".") != nil && userIsTyping {
                return
            }
            if userIsTyping {
                display.text = currentDisplay + digit
            } else {
                display.text = digit
            }
            userIsTyping = true
        }
    }
    
    private var displayValue: Double {
        get {
            return Double(display.text!)!
        }
        set {
            display.text = doubleAsString(newValue)
        }
    }
    
    private var brain = CalculatorBrain()

    @IBAction private func performOperation(sender: UIButton) {
        let userWasTyping = userIsTyping
        if userIsTyping {
            brain.setOperand(displayValue)
            userIsTyping = false
        }
        if let operation = sender.currentTitle {
            brain.performOperation(operation, userWasTyping: userWasTyping)
        }
        updateLabels()
    }
    
    @IBAction func touchClear() {
        brain.clear()
        updateLabels()
    }

    private func updateLabels() {
        displayValue = brain.result
        if var newDescription = brain.description {
            newDescription += brain.isPartialResult ? " ..." : " ="
            descriptionDisplay.text = newDescription
        } else {
            descriptionDisplay.text = " "
        }
    }
}

