//
//  ViewController.swift
//  Calculator2.0
//
//  Created by Gianni Maize on 4/14/17.
//  Copyright © 2017 Maize Man. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var userIsInTheMiddleOfTyping = false
    
    @IBOutlet weak var display: UILabel!

    @IBOutlet weak var historyDisplay: UILabel!
    
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
        historyDisplay.text = " "
        userIsInTheMiddleOfTyping = false
        brain.reset()
    }
    
    @IBAction func deleteDigit(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping && display.text!.characters.count > 1 {
            display.text!.remove(at: display.text!.index(before: display.text!.endIndex))
        } else if userIsInTheMiddleOfTyping {
            userIsInTheMiddleOfTyping = false
            display.text = "0"
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
        if let result = brain.result {
            displayValue = result
        }
        historyDisplay.text = brain.description
        if brain.resultIsPending {
            historyDisplay.text! += "..."
        } else {
            historyDisplay.text! += "="
        }
    }
}

