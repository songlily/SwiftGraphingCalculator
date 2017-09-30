//
//  CalculatorModel.swift
//  Calculator
//
//  Created by Lily Song on 2017-09-21.
//  Copyright © 2017 Lily Song. All rights reserved.
//

import Foundation

func fact(n: Double) -> Double {                                            // factorial function
    if n >= 0 {
        var a = n, b = 1.0
        while a != 0 {
            b = b * a
            a -= 1
        }
        return b
    } else {
        //neg fact
        return 0/0
    }
}

struct CalculatorModel {
    
    private var accumulator: Double?
    private var accumDescription = " "                                      // created to log all operators+operands in an equation for description
    
    private enum Operation {
        case clear
        case constant(Double)
        case unaryOperation((Double) -> Double)
        case binaryOperation((Double, Double) -> Double)
        case equals
    }
    
    private var operations: [String:Operation] = [
        "C": Operation.clear,

        "+": Operation.binaryOperation(+),
        "−": Operation.binaryOperation(-),
        "×": Operation.binaryOperation(*),
        "÷": Operation.binaryOperation(/),
        "=": Operation.equals,
        
        "±": Operation.unaryOperation({-$0}),                       //before
        "x²": Operation.unaryOperation({$0*$0}),                       //after
        "√": Operation.unaryOperation(sqrt),                       //before
        "!": Operation.unaryOperation(fact),                        //after
        
        "%": Operation.unaryOperation({$0/100}),                       //after
        "π": Operation.constant(Double.pi),
        "e": Operation.constant(M_E),
        "ln": Operation.unaryOperation(log),                       //before

        "sin": Operation.unaryOperation(sin),                       //before
        "cos": Operation.unaryOperation(cos),
        "tan": Operation.unaryOperation(tan)
        
    ]
    
    mutating func performOperation (_ symbol: String) {
        
        accumDescription = accumDescription.replacingOccurrences(of: " ...", with: "")          //remove ellipsis
        
        if let operation = operations[symbol]  {
            switch operation {
            case .constant(let value):
                if (lastUnary || accumDescription.contains("=")) {                                          //if last operation was a unary operation, clear description
                    accumDescription = " "
                }
                accumulator = value
                accumDescription += "\(symbol)"                                //show symbol for constants in description
                
            case .unaryOperation (let function):
                if lastUnary {
                    accumDescription = " "
                }
                let descriptionHasEquals = accumDescription.contains("=")
                accumDescription = accumDescription.components(separatedBy: " ").dropLast().joined(separator: " ")
                if accumulator != nil {
                    if (symbol == "x²" || symbol == "!" || symbol == "%") {                                     //used an if statement to separate the symbols that go after the number
                        if descriptionHasEquals {
                        accumDescription = " (\(accumDescription))\(symbol)"
                        } else {
                            accumDescription += " \(stringValueForAccumulator())\(symbol)"
                        }
                        accumDescription = accumDescription.replacingOccurrences(of: "x", with: "")             //take out x if x²
                    } else {
                        if descriptionHasEquals {
                            accumDescription = " \(symbol) (\(accumDescription))"                          //show " (symbol)"
                        } else {
                            accumDescription += " \(symbol) (\(stringValueForAccumulator()))"
                        }
                    }
                }
                accumulator = function(accumulator!)
                lastUnary = true
                
            case .binaryOperation (let function):
                if accumDescription.contains("=") {                                         // if already contains complete equation, clear description
                    accumDescription = accumDescription.components(separatedBy: " ").dropLast().joined(separator: " ")
                }
                if accumulator != nil {
                    if (accumDescription == " ") {
                        accumDescription += stringValueForAccumulator()
                    }
                    if resultIsPending {                                                //if pending binary operations, process
                        accumulator = pendingBinaryOperation!.perform(with: accumulator!)
                    }
                    pendingBinaryOperation = PendingBinOp (function: function, firstOp: accumulator!)
                    
                    accumDescription = accumDescription.replacingOccurrences(of: " ...", with: "")
                    accumDescription += " \(symbol) "                             //show " (symbol) "
                    accumulator = nil
                    lastUnary = false
                }
                
            case .equals:
                if accumDescription.contains("=") {                                         // if already contains complete equation, clear description
                    accumDescription = " "
                }
                if accumulator != nil {
                    if resultIsPending {                                                    //process pending binary operations if any
                        accumulator = pendingBinaryOperation!.perform(with: accumulator!)
                        pendingBinaryOperation = nil
                    }
                    accumDescription += " ="
                }
                lastUnary = false
                
            case .clear:                                                        //clears all values or returns to default
                accumulator = 0
                accumDescription = " "
                pendingBinaryOperation = nil
                lastUnary = false
            }
            
        }
        if resultIsPending {                                                    //use the bool to check if I should add ellipsis
            accumDescription += " ..."
        }
        
    }
    
    private func stringValueForAccumulator() -> String {
        if Double(Int(accumulator!)) == accumulator! {
            return String(Int(accumulator!))
        } else {
            return String(accumulator!)
        }
    }
    
    private var resultIsPending : Bool {
        return pendingBinaryOperation != nil
    }
    
    var description: String? {                                                    //lists what user has typed; use resultIsPending Bool??
        get {
            return accumDescription                                                 //accumulate elsewhere?
        }
        // set
    }

    private var lastUnary = false                                                   //checks if last operation was a unary operation
    private var pendingBinaryOperation: PendingBinOp?

    private struct PendingBinOp {
        let function: (Double, Double) -> Double
        let firstOp: Double
        
        func perform (with secondOp: Double) -> Double {
            return function (firstOp, secondOp)
        }
    }

    mutating func setOperand (_ operand: Double) {
        accumulator = operand
        if accumDescription.contains("=") || lastUnary {                                         // if already contains complete equation, clear
            accumDescription = " "
        }
        accumDescription += stringValueForAccumulator()                           //add to description whatever user types in
    }
    
    var result: Double? {
        get {
            return accumulator
        }
    }
}
