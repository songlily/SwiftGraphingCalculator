//
//  ViewController.swift
//  Calculator
//
//  Created by Lily Song on 2017-09-17.
//  Copyright © 2017 Lily Song. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var typed: UILabel!                    //label for description
    private var model = CalculatorModel ()
    
    private var saved = ["M":  0.0]

    var isTyping = false
    var displayValue: Double {
        get {
            return Double(display.text!)!
        }
        set {
            if Double(Int(newValue)) == newValue {
                display.text = String(Int(newValue))
            } else {
                display.text = String(newValue)
            }
        }
    }
    
    @IBAction func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        
        if isTyping {
            if (digit != "." || !display.text!.contains(".")) {        //if num or no deci, register
                let textDisplayed = display.text!
                display.text = textDisplayed + digit
            }
        } else {
            display.text = digit
            isTyping = true
        }
    }
    
    @IBAction func performOperation(_ sender: UIButton) {
        
        if isTyping {
            model.setOperand(displayValue)
            isTyping = false
        }
        
        if let mathSymbol = sender.currentTitle {
            model.performOperation(mathSymbol)
        }
        
        let evaluatedResult = model.evaluate()
        
        //if let result = model.result {
        if let result = evaluatedResult.result {
            displayValue = result
        
        }
        //typed.text = model.description
        typed.text = evaluatedResult.description                  //description shows up in label
    }
    
    @IBAction func memory(_ sender: UIButton) {
        
        /*if sender.currentTitle == "→M" {
            saved["M"] = displayValue
            isTyping = false
        }
        
        if sender.currentTitle == "M" {
            model.setOperand(variable: "M")
            isTyping = false
        }
        
        let evaluatedResult = model.evaluate(using: saved)
        displayValue = evaluatedResult.result ?? 0       //could be nil
        typed.text = evaluatedResult.description*/
        
    }
    
}

