//
//  ViewController.swift
//  Calculator
//
//  Created by Kevin Pfefferle on 5/22/16.
//  Copyright © 2016 Kevin Pfefferle. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController {
    
    // MARK: Model
    
    private var brain = CalculatorBrain()
    
    @IBAction private func setVariable() {
        brain.variableValues["M"] = displayValue
        userIsTyping = false
        updateUI()
    }
    
    @IBAction private func useVariable() {
        brain.setOperand("M")
        updateUI()
    }
    
    @IBAction private func touchClear() {
        brain.variableValues.removeValueForKey("M")
        brain.clear()
        updateUI()
    }
    
    // MARK: View

    @IBOutlet private weak var display: UILabel!
    @IBOutlet private weak var descriptionDisplay: UILabel!
    
    private var userIsTyping = false
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

    private func formattedStringFromDouble(number: Double) -> String? {
        let formatter = NSNumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 6
        return formatter.stringFromNumber(number)
    }

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
    
    @IBAction private func touchUndo() {
        if let currentDisplay = display.text {
            if currentDisplay.characters.count > 1 {
                display.text = String(currentDisplay.characters.dropLast())
            } else if currentDisplay != "0" {
                display.text = "0"
            } else if var brainProgram = brain.program as? [AnyObject] {
                brainProgram.removeLast()
                brain.program = brainProgram
                updateUI()
            }
        }
    }
    
    @IBAction private func touchRand() {
        displayValue = Double(arc4random()) / 0xFFFFFFFF
    }
    
    @IBAction private func performOperation(sender: UIButton) {
        if let displayValue = displayValue
          where userIsTyping {
            brain.setOperand(displayValue)
            userIsTyping = false
        }
        if let operation = sender.currentTitle {
            brain.performOperation(operation)
        }
        updateUI()
    }
    
    private func updateUI() {
        displayValue = brain.result
        if var newDescription = brain.description {
            newDescription += brain.isPartialResult ? " ..." : " ="
            descriptionDisplay.text = newDescription
        } else {
            descriptionDisplay.text = " "
        }
    }

    // MARK: - Navigation

    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        return !brain.isPartialResult && brain.description != nil
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var destinationVC = segue.destinationViewController
        if let navcon = destinationVC as? UINavigationController {
            destinationVC = navcon.visibleViewController ?? destinationVC
        }
        if let graphVC = destinationVC as? GraphViewController,
          let identifier = segue.identifier
          where identifier == "showGraphSegue" {
            graphVC.navigationItem.title = brain.description
            graphVC.program = brain.program
        }
    }
    
}

