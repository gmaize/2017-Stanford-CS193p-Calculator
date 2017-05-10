//
//  CalculatorBrain.swift
//  Calculator2.0
//
//  Created by Gianni Maize on 4/16/17.
//  Copyright © 2017 Maize Man. All rights reserved.
//

import Foundation

public struct CalculatorBrain {
    
    private var accumulator: (Double?, String) = (nil, "")
    
    public var description: String {
        get{
            return resultIsPending ? pendingBinaryOperation!.describe(pendingBinaryOperation!.firstOperandDescription, "") : accumulator.1
        }
    }
    
    private enum Operation {
        case constant(Double)
        case unaryOperation((Double)->Double, (String)->String)
        case binaryOperation((Double, Double)->Double, (String, String) -> String)
        case equals
    }
    
    private var operations: Dictionary<String, Operation> = [
        "π": Operation.constant(Double.pi),
        "e": Operation.constant(M_E),
        "√": Operation.unaryOperation(sqrt, {"√(\($0))"}),
        "cos": Operation.unaryOperation(cos, {"cos(\($0))"}),
        "−": Operation.binaryOperation({ $0 - $1 }, {"\($0)-\($1)"}),
        "±": Operation.unaryOperation({-$0}, {"-(\($0))"}),
        "×": Operation.binaryOperation({$0*$1}, {"\($0)x\($1)"}),
        "+": Operation.binaryOperation({$0+$1}, {"\($0)+\($1)"}),
        "÷": Operation.binaryOperation({$0/$1}, {"\($0)÷\($1)"}),
        "=": Operation.equals,
        "^": Operation.binaryOperation(pow, {"\($0)^\($1)"}),
        "log": Operation.unaryOperation(log, {"log(\($0))"}),
        "tan": Operation.unaryOperation(tan, {"tan(\($0))"}),
        "sin": Operation.unaryOperation(sin, {"sin(\($0))"})
    ]
    
    mutating func performOperation(_ symbol: String) {
        if let operation = operations[symbol] {
            switch operation {
            case .constant(let value):
                accumulator = (value, symbol)
            case .unaryOperation(let function, let description):
                if accumulator.0 != nil {
                    accumulator = (function(accumulator.0!), description(accumulator.1))
                }
            case .binaryOperation(let function, let fxnDescribe):
                if accumulator.0 != nil {
                    performPendingBinaryOperation()
                    pendingBinaryOperation = PendingBinaryOperation(function: function, describe: fxnDescribe, firstOperand: accumulator.0!, firstOperandDescription: accumulator.1)
                    accumulator = (nil, "")
                }
            case .equals:
                performPendingBinaryOperation()
            }
        }
    }
    
    private mutating func performPendingBinaryOperation() {
        if pendingBinaryOperation != nil && accumulator.0 != nil {
            let val = pendingBinaryOperation!.performWith(secondOperand: accumulator.0!)
            let description = pendingBinaryOperation!.describe(pendingBinaryOperation!.firstOperandDescription, accumulator.1)
            accumulator = (val, description)
            pendingBinaryOperation = nil
        }
    }
    
    mutating func setOperand(_ operand: Double) {
        accumulator = (operand, String(operand))
    }
    
    private var variables: Dictionary<String, Double> = [:]
    
    
    var result: Double? {
        get {
            return accumulator.0
        }
    }

    
    private var pendingBinaryOperation: PendingBinaryOperation?
    
    public var resultIsPending : Bool {
        get{
            return pendingBinaryOperation != nil
        }
    }
    
    public mutating func reset() {
        accumulator = (nil, "")
        pendingBinaryOperation = nil
    }
    
    private struct PendingBinaryOperation {
        let function: (Double, Double) -> Double
        let describe: (String, String) -> String

        let firstOperand: Double
        let firstOperandDescription: String
        
        func performWith(secondOperand: Double) -> Double {
            return function(self.firstOperand, secondOperand)
        }
    }
}
