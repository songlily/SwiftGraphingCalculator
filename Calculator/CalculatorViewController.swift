//
//  CalculatorViewController.swift
//  Calculator
//
//  Created by Lily Song on 2017-09-17.
//  Copyright © 2017 Lily Song. All rights reserved.
//

import UIKit

struct GetFunction {
    private var model: CalculatorModel
    init(passedModel: CalculatorModel) {
        self.model = passedModel
    }
    
    func evaluate(with x: Double) -> Double? {
        if !model.evaluate().isPending {
            let evaluated = model.evaluate(using: ["M": x])
            let result = evaluated.result
            return result
        } else {
            return nil
        }
    }
}

class CalculatorViewController: UIViewController {

    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var typed: UILabel!                    //label for description
    @IBOutlet weak var memoryLabel: UILabel!
    private var model = CalculatorModel ()
    private var saved = [String: Double]()
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let getFunction = GetFunction(passedModel: model)
        var destinationViewController = segue.destination
        if let navigationController = destinationViewController as? UINavigationController {
            destinationViewController = navigationController.visibleViewController ?? destinationViewController
        }
        if let graphingViewController = destinationViewController as? GraphingViewController,
           !model.evaluate().isPending {
            
            //set description for graphLabel
            if model.evaluate().description.contains("=") {
                graphingViewController.graphText = "y = \(model.evaluate().description.components(separatedBy: " ").dropLast().joined(separator: " "))"
            } else if model.evaluate().description == " " {
                graphingViewController.graphText = " "
            } else {
                graphingViewController.graphText = "y = \(model.evaluate().description)"
            }
            //push instance of getFunction to graphingViewController
            graphingViewController.functionWrapper = getFunction
        }
    }
    
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
        if display.text!.characters.first == "0" && display.text!.characters.count > 1 {
            display.text = String(display.text!.characters.dropFirst())
        }
    }
    
    @IBAction func performOperation(_ sender: UIButton) {
        
        if sender.currentTitle == "←" {
            //isTyping && !display.text.isEmpty, dropLast()
            //isTyping && display.text.isEmpty, = 0 + model.undo() + !isTyping
            //!isTyping, model.undo()
            
            if isTyping && !display.text!.isEmpty {
                let back = display.text!.characters.dropLast()
                display.text = String(back)
            } else if isTyping && display.text!.isEmpty {
                display.text = "0"
                model.undo()
                isTyping = false
            } else if typed.text! != " "{
                model.undo()
            } else {
                display.text = "0"
            }
            if display.text == "" {
                display.text = "0"
                isTyping = false
            }
            
        } else {
            
            if sender.currentTitle == "C" {
                saved = [:]
                memoryLabel.text = " "
            }
            
            if isTyping {
                model.setOperand(displayValue)
                isTyping = false
            }
            
            if let mathSymbol = sender.currentTitle {
                model.performOperation(mathSymbol)
            }
            
        }
        
        let evaluated = model.evaluate(using: saved)
        
        if let result = evaluated.result {
            displayValue = result
        }
        typed.text = evaluated.description                  //description shows up in label
    }
    
    @IBAction func memory(_ sender: UIButton) {
        
        if sender.currentTitle == "→M" {
            saved["M"] = displayValue
            memoryLabel.text = "M = \(displayValue)"
            isTyping = false
        }
        
        if sender.currentTitle == "M" {
            model.setOperand(variable: "M")
            isTyping = false
        }
        
        let evaluated = model.evaluate(using: saved)
        displayValue = evaluated.result ?? 0       //could be nil
        typed.text = evaluated.description
        
    }
    
}

