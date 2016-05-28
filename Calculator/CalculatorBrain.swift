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
    }
    
    private enum Operation {
        case Constant(Double)
        case UnaryOperation((Double) -> Double)
        case BinaryOperation((Double, Double) -> Double)
        case Equals
        case Clear
    }
    
    private var operations: Dictionary<String,Operation> = [
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
        "=" : Operation.Equals,
        "C" : Operation.Clear
    ]
    
    func performOperation(symbol: String, userWasTyping: Bool) {
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
            case .Clear:
                accumulator = 0.0
                descriptionString = nil
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
    
    private var descriptionString: String?
    
    private func appendStringToDescription(string: String, userWasTyping: Bool) {
        if descriptionString == nil ||
          (!isPartialResult && userWasTyping) {
            descriptionString = string
        } else {
            descriptionString! += " \(string)"
        }
    }
    
    private var constantWasUsed = false
    private var equalsSkipAccumulator = false
    
    private func updateDescription(symbol: String, userWasTyping: Bool) {
        if let operation = operations[symbol] {
            switch operation {
            case .Constant:
                constantWasUsed = true
            case .UnaryOperation:
                let stringToWrap = (userWasTyping || descriptionString == nil) ? accumulatorString : descriptionString!
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
                    descriptionString = newDescriptionContent
                }
                constantWasUsed = false
                equalsSkipAccumulator = true
            case .BinaryOperation:
                var newDescriptionContent = ""
                if userWasTyping || constantWasUsed {
                    newDescriptionContent += "\(accumulatorString) "
                }
                newDescriptionContent += "\(symbol)"
                appendStringToDescription(newDescriptionContent, userWasTyping: userWasTyping)
                constantWasUsed = false
                equalsSkipAccumulator = false
            case .Equals:
                if !equalsSkipAccumulator {
                    appendStringToDescription(accumulatorString, userWasTyping: userWasTyping)
                }
                constantWasUsed = false
                equalsSkipAccumulator = true
            default:
                constantWasUsed = false
                equalsSkipAccumulator = false
                return
            }
        }
    }
    
    var description: String? {
        get {
            return descriptionString
        }
    }
    
    var result: Double {
        get {
            return accumulator
        }
    }

}