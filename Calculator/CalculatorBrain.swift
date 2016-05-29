//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Kevin Pfefferle on 5/22/16.
//  Copyright © 2016 Kevin Pfefferle. All rights reserved.
//

import Foundation

func doubleAsString(number: Double) -> String {
    if number == Double(Int(number)) {
        return String(Int(number))
    } else {
        return String(number)
    }
}

class CalculatorBrain {
    
    private var accumulator = 0.0
    private var internalProgram = [AnyObject]() {
        didSet {
            if let operation = oldValue.last as? String,
              let operand = internalProgram.last as? Double
              where operation == "=" {
                internalProgram = [ operand ]
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
            default: return doubleAsString(accumulator)
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
            return internalDescription
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
    
}