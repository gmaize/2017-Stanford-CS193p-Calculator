//
//  ViewController.swift
//  Calculator2.0
//
//  Created by Gianni Maize on 4/14/17.
//  Copyright © 2017 Maize Man. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var variables = Dictionary<String, Double>()
    
    var userIsInTheMiddleOfTyping = false
    
    @IBOutlet weak var display: UILabel!

    @IBOutlet weak var historyDisplay: UILabel!
    
    @IBOutlet weak var variablesDisplay: UILabel!
    
    @IBAction func touchDigit(_ sender: UIButton) {
        if !brain.resultIsPending {
            historyDisplay.text = " "
        }
        let digit = sender.currentTitle!
        if digit == "." && (!userIsInTheMiddleOfTyping || display.text!.contains(".")) {
            return
        }
        if userIsInTheMiddleOfTyping {
            let textCurrentlyInDisplay = display.text!
            display.text = textCurrentlyInDisplay + digit
        } else {
            display.text = digit
            userIsInTheMiddleOfTyping = true
        }
    }
    
    @IBAction func resetCalculator(_ sender: UIButton) {
        display.text = "0"
        historyDisplay.text = ""
        variables.removeAll(keepingCapacity: true)
        updateVariableDisplay()
        userIsInTheMiddleOfTyping = false
        brain.reset()
    }
    

    @IBAction func undo(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping && display.text!.characters.count > 1 {
            display.text!.remove(at: display.text!.index(before: display.text!.endIndex))
        } else if userIsInTheMiddleOfTyping {
            userIsInTheMiddleOfTyping = false
            display.text = "0"
        } else {
            brain.undo()
            evaluate()
        }
    }
    
    @IBAction func storeVariable(_ sender: UIButton) {
        if let senderName = sender.currentTitle {
            let variableName = senderName.replacingOccurrences(of: "→", with: "")
            variables[variableName] = displayValue
            updateVariableDisplay()
        }
        evaluate()
    }
    
    private func updateVariableDisplay() {
        var variablesText = ""
        for (variable, value) in variables {
            variablesText += "\(variable)=\(value), "
        }
        if variablesText.characters.count > 2 {
            variablesText = String(variablesText.characters.dropLast(2))
        }
        variablesDisplay!.text = variablesText
    }
    
    @IBAction func setVariable(_ sender: UIButton) {
        if let variableName = sender.currentTitle {
            brain.setOperand(variable: variableName)
        }
        evaluate()
    }
    
    
    func evaluate() {
        let (result, resultIsPending, description) = brain.evaluate(using: variables)
        if (result != nil) {
            displayValue = result!
        } else if (result == nil && resultIsPending) {
            
        } else {
        }
        
        historyDisplay.text = description
        if resultIsPending {
            historyDisplay.text! += "..."
        } else if result != nil {
            historyDisplay.text! += "="
        }
    }
    
    var displayValue: Double {
        get {
            return Double(display.text!)!
        }
        set {
            display.text = String(newValue)
        }
    }
    
    private var brain = CalculatorBrain()
    
    @IBAction func performOperation(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            brain.setOperand(displayValue)
            userIsInTheMiddleOfTyping = false
        }
        if let mathSymbol = sender.currentTitle {
            brain.performOperation(mathSymbol)
        }
        evaluate()
    }
}

