//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Kevin Pfefferle on 5/22/16.
//  Copyright © 2016 Kevin Pfefferle. All rights reserved.
//

import Foundation

class CalculatorBrain {
    
    private var accumulator = 0.0
    private var internalProgram = [AnyObject]() {
        didSet {
            var mutableOldValue = oldValue
            if let operand = internalProgram.last as? Double,
              let symbol = oldValue.last as? String
              where symbol == "=" {
                internalProgram = [ operand ]
            } else if let operand = internalProgram.last as? Double,
              let symbol = mutableOldValue.popLast() as? String,
              let operation = operations[symbol],
              case .UnaryOperation = operation,
              let prevSymbol = mutableOldValue.popLast() as? String
              where prevSymbol == "=" {
                internalProgram = [ operand ]
            } else if let previousOp = oldValue.last as? String,
              let newOp = internalProgram.last as? String
              where previousOp == "=" && newOp == "=" {
                internalProgram = oldValue
            }
        }
    }
    private var internalDescription: String?
    private var previousOperation = Operation.Equals
    
    private var accumulatorString: String {
        get {
            switch accumulator {
            case M_PI: return "π"
            case M_E: return "e"
            default: return formattedStringFromDouble(accumulator)!
            }
        }
    }
    
    func setOperand(operand: Double) {
        accumulator = operand
        internalProgram.append(operand)
    }
    
    private enum Operation {
        case Constant(Double)
        case UnaryOperation((Double) -> Double)
        case BinaryOperation((Double, Double) -> Double)
        case Equals
    }
    
    private var operations: [String:Operation] = [
        "π" : Operation.Constant(M_PI),
        "e" : Operation.Constant(M_E),
        "%" : Operation.UnaryOperation({ $0 / 100 }),
        "sin" : Operation.UnaryOperation(sin),
        "cos" : Operation.UnaryOperation(cos),
        "tan" : Operation.UnaryOperation(tan),
        "√" : Operation.UnaryOperation(sqrt),
        "x²" : Operation.UnaryOperation({ $0 * $0 }),
        "×" : Operation.BinaryOperation({ $0 * $1 }),
        "÷" : Operation.BinaryOperation({ $0 / $1 }),
        "+" : Operation.BinaryOperation({ $0 + $1 }),
        "−" : Operation.BinaryOperation({ $0 - $1 }),
        "=" : Operation.Equals
    ]
    
    func performOperation(symbol: String, userWasTyping: Bool) {
        internalProgram.append(symbol)
        if let operation = operations[symbol] {
            updateDescription(symbol, userWasTyping: userWasTyping)
            switch operation {
            case .Constant(let value):
                accumulator = value
            case .UnaryOperation(let function):
                accumulator = function(accumulator)
            case .BinaryOperation(let function):
                executePendingBinaryOperation()
                pending = PendingBinaryOperation(binaryFunction: function, firstOperand: accumulator)
            case .Equals:
                executePendingBinaryOperation()
            }
        }
    }
    
    private var pending: PendingBinaryOperation?
    
    private struct PendingBinaryOperation {
        var binaryFunction: (Double, Double) -> Double
        var firstOperand: Double
    }

    var isPartialResult: Bool {
        get {
            return pending != nil
        }
    }
    
    private func executePendingBinaryOperation() {
        if pending != nil {
            accumulator = pending!.binaryFunction(pending!.firstOperand, accumulator)
            pending = nil
        }
    }
    
    typealias PropertyList = AnyObject
    
    var program: PropertyList {
        get {
            return internalProgram
        }
        set {
            clear()
            if let arrayOfOps = newValue as? [AnyObject] {
                for op in arrayOfOps {
                    if let operand = op as? Double {
                        setOperand(operand)
                    } else if let operation = op as? String {
                        performOperation(operation, userWasTyping: false)
                    }
                }
            }
        }
    }
    
    private func appendStringToDescription(string: String, userWasTyping: Bool) {
        var userWasTypingOverride = userWasTyping
        if case .Constant = previousOperation {
            userWasTypingOverride = true
        }
        if internalDescription == nil ||
          (!isPartialResult && userWasTypingOverride) {
            internalDescription = string
        } else {
            internalDescription! += " \(string)"
        }
    }
    
    private func updateDescription(symbol: String, userWasTyping: Bool) {
        if let operation = operations[symbol] {
            switch operation {
            case .UnaryOperation:
                let stringToWrap = (userWasTyping || internalDescription == nil) ? accumulatorString : internalDescription!
                var newDescriptionContent = ""
                switch symbol {
                case "x²":
                    newDescriptionContent = "(\(stringToWrap))²"
                case "%":
                    newDescriptionContent = "(\(stringToWrap))%"
                default:
                    newDescriptionContent = "\(symbol)(\(stringToWrap))"
                }
                if userWasTyping {
                    appendStringToDescription(newDescriptionContent, userWasTyping: userWasTyping)
                } else {
                    internalDescription = newDescriptionContent
                }
            case .BinaryOperation:
                var newDescriptionContent = ""
                if userWasTyping {
                    newDescriptionContent += "\(accumulatorString) "
                } else if case .Constant = previousOperation {
                    newDescriptionContent += "\(accumulatorString) "
                }
                newDescriptionContent += "\(symbol)"
                appendStringToDescription(newDescriptionContent, userWasTyping: userWasTyping)
            case .Equals:
                switch previousOperation {
                case .UnaryOperation, .Equals:
                    if userWasTyping {
                        fallthrough
                    } else {
                        break
                    }
                default:
                    appendStringToDescription(accumulatorString, userWasTyping: userWasTyping)
                }
            default:
                break
            }
            previousOperation = operation
        }
    }
    
    var description: String? {
        get {
            NSLog("internalDescription: \(internalDescription)")
            NSLog("descriptionString: '\(descriptionString())'")
            return internalDescription
        }
    }
    
    private func descriptionString() -> String {
        var descriptionElements = [String]()
        var lastItem: AnyObject?
        var lastOperand: Double?
        for item in internalProgram {
            if let operand = item as? Double,
              let formattedOperand = formattedStringFromDouble(operand) {
                descriptionElements.append(formattedOperand)
                lastOperand = operand
            } else if let symbol = item as? String,
              let operation = operations[symbol] {
                switch operation {
                case .Constant:
                    descriptionElements.append(symbol)
                case .UnaryOperation:
                    if let operation = lastItem as? String
                      where operation == "=" {
                        let descriptionString = descriptionElements.joinWithSeparator(" ")
                        descriptionElements.removeAll()
                        descriptionElements.append(wrapContentWithSymbol(symbol, content: descriptionString))
                    } else if let operand = lastItem as? Double,
                      let formattedOperand = formattedStringFromDouble(operand) {
                        descriptionElements.removeLast()
                        descriptionElements.append(wrapContentWithSymbol(symbol, content: formattedOperand))
                    }
                case .BinaryOperation:
                    if let lastOperation = lastItem as? String,
                      let operation = operations[lastOperation],
                      case .BinaryOperation = operation,
                      let lastOperand = lastOperand,
                      let formattedLastOperand = formattedStringFromDouble(lastOperand) {
                        descriptionElements.append(formattedLastOperand)
                    }
                    descriptionElements.append(symbol)
                case .Equals:
                    if let lastOperation = lastItem as? String,
                      let operation = operations[lastOperation],
                      case .BinaryOperation = operation,
                      let lastOperand = lastOperand,
                      let formattedLastOperand = formattedStringFromDouble(lastOperand) {
                        descriptionElements.append(formattedLastOperand)
                    }
                }
            }
            lastItem = item
        }
        return descriptionElements.joinWithSeparator(" ")
    }
    
    private func wrapContentWithSymbol(symbol: String, content: String) -> String {
        switch symbol {
        case "x²":
            return "(\(content))²"
        case "%":
            return "(\(content))%"
        default:
            return "\(symbol)(\(content))"
        }
    }
    
    var result: Double {
        get {
            return accumulator
        }
    }

    func clear() {
        accumulator = 0.0
        pending = nil
        internalProgram.removeAll()
        previousOperation = Operation.Equals
        internalDescription = nil
    }
    
    private func formattedStringFromDouble(number: Double) -> String? {
        let formatter = NSNumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 6
        return formatter.stringFromNumber(number)
    }

}