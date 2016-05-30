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
    
    @IBAction private func touchBackspace() {
        if let currentDisplay = display.text {
            if currentDisplay.characters.count > 1 {
                display.text = String(currentDisplay.characters.dropLast())
            } else {
                display.text = "0"
            }
        }
    }
    
    @IBAction func touchRand() {
        displayValue = Double(arc4random()) / 0xFFFFFFFF
    }
    
    private var displayValue: Double? {
        get {
            return Double(display.text!)
        }
        set {
            if newValue == nil {
                display.text = "0"
            } else if let formattedValue = formattedStringFromDouble(newValue!) {
                display.text = formattedValue
            }
        }
    }
    
    private var brain = CalculatorBrain()

    @IBAction private func performOperation(sender: UIButton) {
        if let displayValue = displayValue
          where userIsTyping {
            brain.setOperand(displayValue)
            userIsTyping = false
        }
        if let operation = sender.currentTitle {
            brain.performOperation(operation)
        }
        updateLabels()
    }
    
    @IBAction private func touchClear() {
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
    
    private func formattedStringFromDouble(number: Double) -> String? {
        let formatter = NSNumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 6
        return formatter.stringFromNumber(number)
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.All
    }
}

