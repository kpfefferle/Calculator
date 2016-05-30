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
    
    func performOperation(symbol: String) {
        internalProgram.append(symbol)
        if let operation = operations[symbol] {
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
        return pending != nil
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
                        performOperation(operation)
                    }
                }
            }
        }
    }
    
    var description: String? {
        guard !internalProgram.isEmpty else {
            return nil
        }
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
                    if let operand = lastItem as? Double,
                        let formattedOperand = formattedStringFromDouble(operand) {
                        descriptionElements.removeLast()
                        descriptionElements.append(wrapContentWithSymbol(symbol, content: formattedOperand))
                    } else if let lastSymbol = lastItem as? String,
                        let lastOperation = operations[lastSymbol] {
                        switch lastOperation {
                        case .UnaryOperation, .Equals:
                            let descriptionString = descriptionElements.joinWithSeparator(" ")
                            descriptionElements.removeAll()
                            descriptionElements.append(wrapContentWithSymbol(symbol, content: descriptionString))
                        default:
                            break
                        }
                    }
                case .BinaryOperation:
                    if let lastSymbol = lastItem as? String,
                        let lastOperation = operations[lastSymbol],
                        case .BinaryOperation = lastOperation,
                        let lastOperand = lastOperand,
                        let formattedLastOperand = formattedStringFromDouble(lastOperand) {
                        descriptionElements.append(formattedLastOperand)
                    }
                    descriptionElements.append(symbol)
                case .Equals:
                    if let lastSymbol = lastItem as? String,
                        let lastOperation = operations[lastSymbol],
                        case .BinaryOperation = lastOperation,
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
        return accumulator
    }

    func clear() {
        accumulator = 0.0
        pending = nil
        internalProgram.removeAll()
    }
    
    private func formattedStringFromDouble(number: Double) -> String? {
        let formatter = NSNumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 6
        return formatter.stringFromNumber(number)
    }

}