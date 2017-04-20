//
//  CalculatorBrain.swift
//  Calculator2.0
//
//  Created by Gianni Maize on 4/16/17.
//  Copyright © 2017 Maize Man. All rights reserved.
//

import Foundation

struct CalculatorBrain {
    
    private var accumulator: Double?
    
    public var description: String {
        get{
            return descriptionPrefix + pendingOperandDescription
        }
    }
    private var pendingOperandDescription : String = ""
    private var descriptionPrefix : String = ""
    
    private enum Operation {
        case constant(Double)
        case unaryOperation((Double)->Double)
        case binaryOperation((Double, Double)->Double)
        case equals
    }
    
    
    private var operations: Dictionary<String, Operation> = [
        "π": Operation.constant(Double.pi),
        "e": Operation.constant(M_E),
        "√": Operation.unaryOperation(sqrt),
        "cos": Operation.unaryOperation(cos),
        "−": Operation.binaryOperation({ $0 - $1 }),
        "±": Operation.unaryOperation({-$0}),
        "×": Operation.binaryOperation({$0*$1}),
        "+": Operation.binaryOperation({$0+$1}),
        "÷": Operation.binaryOperation({$0/$1}),
        "=": Operation.equals,
        "^": Operation.binaryOperation(pow),
        "log": Operation.unaryOperation(log),
        "tan": Operation.unaryOperation(tan),
        "sin": Operation.unaryOperation(sin)
    ]
    
    mutating func performOperation(_ symbol: String) {
        if let operation = operations[symbol] {
            switch operation {
            case .constant(let value):
                accumulator = value
                if resultIsPending {
                    pendingOperandDescription = symbol
                } else {
                    descriptionPrefix = symbol
                }
            case .unaryOperation(let function):
                if accumulator != nil {
                    accumulator = function(accumulator!)
                    if resultIsPending {
                        pendingOperandDescription = "\(symbol)(\(pendingOperandDescription))"
                    } else {
                        descriptionPrefix = "\(symbol)(\(descriptionPrefix))"
                    }
                }
            case .binaryOperation(let function):
                if accumulator != nil {
                    performPendingBinaryOperation()
                    pendingBinaryOperation = PendingBinaryOperation(function: function, firstOperand: accumulator!)
                    accumulator = nil
                    descriptionPrefix = descriptionPrefix + symbol
                }
            case .equals:
                performPendingBinaryOperation()
            }
        }
    }
    
    private mutating func performPendingBinaryOperation() {
        if pendingBinaryOperation != nil && accumulator != nil {
            accumulator = pendingBinaryOperation!.perform(with: accumulator!)
            pendingBinaryOperation = nil
            descriptionPrefix = descriptionPrefix + pendingOperandDescription
            pendingOperandDescription = ""
        }
    }
    
    mutating func setOperand(_ operand: Double) {
        accumulator = operand
        if resultIsPending {
            pendingOperandDescription = String(operand)
        } else {
            descriptionPrefix = String(operand)
        }
    }
    
    var result: Double? {
        get {
            return accumulator
        }
    }

    
    private var pendingBinaryOperation: PendingBinaryOperation?
    
    public var resultIsPending : Bool {
        get{
            return pendingBinaryOperation != nil
        }
    }
    
    public mutating func reset() {
        accumulator = nil
        descriptionPrefix = ""
        pendingOperandDescription = ""
        pendingBinaryOperation = nil
    }
    
    private struct PendingBinaryOperation {
        let function: (Double, Double) -> Double
        let firstOperand: Double
        func perform(with secondOperand: Double) -> Double {
            return function(firstOperand, secondOperand)
        }
    }
}
