//
//  CalculatorBrain.swift
//  Calculator2.0
//
//  Created by Gianni Maize on 4/16/17.
//  Copyright © 2017 Maize Man. All rights reserved.
//

import Foundation

public struct CalculatorBrain {
    
    private var operationSequence: [Operation] = []
    
    public var description: String {
        get{
            return evaluate(using: nil).description
        }
    }
    
    private enum Operation {
        case operand(Double)
        case constant(Double, String)
        case variable(String)
        case unaryOperation((Double)->Double, (String)->String)
        case binaryOperation((Double, Double)->Double, (String, String) -> String)
        case equals
    }
    
    private var operations: Dictionary<String, Operation> = [
        "π": Operation.constant(Double.pi, "π"),
        "e": Operation.constant(M_E, "e"),
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
            operationSequence.append(operation)
        }
    }
    
    mutating func setOperand(_ operand: Double) {
        operationSequence.append(Operation.operand(operand))
    }
    
    mutating func setOperand(variable named: String) {
        operationSequence.append(Operation.variable(named))
    }
    
    func evaluate(using variables: Dictionary<String,Double>? = nil) -> (result: Double?, isPending: Bool, description: String) {
        var result: Double?
        var pendingBinaryOperation: PendingBinaryOperation!
        var resultIsPending : Bool {
            get{
                return pendingBinaryOperation != nil
            }
        }
        var description = ""
        let numOperations = operationSequence.endIndex
        for (index, operation) in operationSequence.enumerated() {
            switch operation {
            case .operand(let value):
                result = value
                description = String(value)
            case .constant(let value, let symbol):
                result = value
                description = symbol
            case .variable(let named):
                result = (variables == nil || variables![named] == nil) ? 0 : variables![named]
                description = named
            case .unaryOperation(let function, let describeWith):
                if result != nil {
                    result = function(result!)
                    description = describeWith(description)
                }
            case .binaryOperation(let function, let describe):
                if result != nil {
                    if (resultIsPending) {
                        result = pendingBinaryOperation!.performWith(secondOperand: result!)
                        description = pendingBinaryOperation!.describe(pendingBinaryOperation.firstOperandDescription, description)
                        pendingBinaryOperation = nil
                    }
                    pendingBinaryOperation = PendingBinaryOperation(function: function, describe: describe, firstOperand: result!, firstOperandDescription: description)
                    result = nil
                    description = pendingBinaryOperation.describe(pendingBinaryOperation.firstOperandDescription, "")
                }
            case .equals:
                if result != nil && resultIsPending {
                    result = pendingBinaryOperation!.performWith(secondOperand: result!)
                    description = pendingBinaryOperation!.describe(pendingBinaryOperation.firstOperandDescription, description)
                    pendingBinaryOperation = nil
                }
            }
            if index == numOperations-1 && resultIsPending {
                switch operation {
                case .operand, .constant, .variable, .unaryOperation:
                    description = pendingBinaryOperation.describe(pendingBinaryOperation.firstOperandDescription, description)
                default:
                    break
                }
            }
        }
        return (result, resultIsPending, description)
    }
    
    public mutating func undo() {
        if !operationSequence.isEmpty {
            operationSequence.removeLast()
        }
    }
    
    var result: Double? {
        get {
            return evaluate(using: nil).result
        }
    }

    
    private var pendingBinaryOperation: PendingBinaryOperation?
    
    public var resultIsPending : Bool {
        get{
            return evaluate(using: nil).isPending
        }
    }
    
    public mutating func reset() {
        operationSequence = []
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
