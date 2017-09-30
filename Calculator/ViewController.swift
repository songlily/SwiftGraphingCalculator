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
    @IBOutlet weak var typed: UILabel!                              //label for description
    
    var isTyping = false
    
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
    
    private var model = CalculatorModel ()
    
    @IBAction func performOperation(_ sender: UIButton) {

        if isTyping {
            model.setOperand(displayValue)
            isTyping = false
        }
        
        if let mathSymbol = sender.currentTitle {
            model.performOperation(mathSymbol)
        }
        if let result = model.result{
            displayValue = result
            
        }
        
        typed.text = model.description                      //description shows up in label

    }
    
}
