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
    
    private var accumulated: (value: Double?, description: String) = (nil, " ")
    private var operand: String?
    private var lastUnary = false                                                   //checks if last operation was a unary operation

    private enum Operation {
        case clear
        case constant(Double)
        case unaryOperation((Double) -> Double, (String) -> String)
        case binaryOperation((Double, Double) -> Double, (Void) -> String) //(String, String) -> String)
        case equals
    }
    
    private var operations: [String:Operation] = [
        "C": Operation.clear,

        "+": Operation.binaryOperation(+, {" + "}),
        "−": Operation.binaryOperation(-, {" - "}),
        "×": Operation.binaryOperation(*, {" × "}),
        "÷": Operation.binaryOperation(/, {" ÷ "}),
        "=": Operation.equals,
        
        "±": Operation.unaryOperation({-$0}, {"-(\($0))"}),                       //before
        "x²": Operation.unaryOperation({$0*$0}, {"(\($0))²"}),                       //after
        "√": Operation.unaryOperation(sqrt, {"√(\($0))"}),                       //before
        "!": Operation.unaryOperation(fact, {"\($0)!"}),                        //after
        
        "%": Operation.unaryOperation({$0/100}, {"\($0)"}),                       //after
        "π": Operation.constant(Double.pi),
        "e": Operation.constant(M_E),
        "ln": Operation.unaryOperation(log, {"ln(\($0))"}),                       //before

        "sin": Operation.unaryOperation(sin, {"sin(\($0))"}),                       //before
        "cos": Operation.unaryOperation(cos, {"cos(\($0))"}),
        "tan": Operation.unaryOperation(tan, {"tan(\($0))"})
    ]
    
    mutating func performOperation (_ symbol: String) {
        
        let descriptionHasEquals = accumulated.description.contains("=")
        accumulated.description = accumulated.description.replacingOccurrences(of: " ...", with: "")          //remove ellipsis
        
        if let operation = operations[symbol]  {
            switch operation {
                
            case .constant(let value):
                if (lastUnary || descriptionHasEquals) {                                          //if last operation was a unary operation, clear description
                    accumulated.description = " "
                }
                accumulated = (value, addToDescription("\(symbol)"))
                
            case .unaryOperation (let function, let descriptionFunction):
                if lastUnary {
                    accumulated.description = " "
                }
                
                accumulated.description = accumulated.description.components(separatedBy: " ").dropLast().joined(separator: " ")
                
                if accumulated.value != nil {
                    if descriptionHasEquals {
                        accumulated = (function(accumulated.value!), descriptionFunction("\(accumulated.description)"))                   //formatting??
                    } else {
                        accumulated = (function(accumulated.value!), addToDescription(descriptionFunction(stringAccumulatedValue())))                   //formatting??
                    }
                }
                
                lastUnary = true
                
            case .binaryOperation (let function, let descriptionFunction):
                if descriptionHasEquals {                                         // if already contains complete equation, clear description
                    accumulated.description = accumulated.description.components(separatedBy: " ").dropLast().joined(separator: " ")
                }
                
                if accumulated.value != nil {
                    
                    //first runthrough, save function as function, accumulator as value // accumDescription as savedDescription
                    //second+ runthough, use saved function+value and return new value, (save function as function, accumulator as value)
                    
                    if resultIsPending {
                        accumulated.value = (pendingBinaryOperation!.perform(with: accumulated.value!))
                        
                    }
                    pendingBinaryOperation = PendingBinOp (function: function, firstOperand: accumulated.value!)
                    
                    accumulated = (nil, addToDescription(descriptionFunction()))
                    lastUnary = false
                }
                
            case .equals:
                if accumulated.value != nil && !descriptionHasEquals {
                    if resultIsPending {
                        accumulated.value = pendingBinaryOperation!.perform(with: accumulated.value!)
                        pendingBinaryOperation = nil
                    }
                    accumulated.description = addToDescription(" =")
                }
                lastUnary = false
                
            case .clear:                                                        //clears all values or returns to default
                accumulated = (0, " ")
                pendingBinaryOperation = nil
                lastUnary = false
            }
        }
        
        if resultIsPending {
            accumulated.description = addToDescription(" ...")
        }
    }
    
    private func stringAccumulatedValue() -> String {
        if Double(Int(accumulated.value!)) == accumulated.value! {
            return String(Int(accumulated.value!))
        } else {
            return String(accumulated.value!)
        }
    }
    
    private func addToDescription (_ addition: String) -> String {
        let newDescription = accumulated.description + addition
        return newDescription
    }
    
    private var pendingBinaryOperation: PendingBinOp?
    private struct PendingBinOp {
        let function: (Double, Double) -> Double
        let firstOperand: Double
        
        func perform (with secondOperand: Double) -> Double {
            return function (firstOperand, secondOperand)
        }
    }
    
    private var resultIsPending : Bool {
        return pendingBinaryOperation != nil
    }

    mutating func setOperand (_ operand: Double) {
        accumulated.value = operand
        if accumulated.description.contains("=") || lastUnary {                                         // if already contains complete equation, clear
            accumulated.description = " "
        }
        accumulated.description = addToDescription(stringAccumulatedValue())
    }
    
    var description: String? {                                                    //lists what user has typed
        get {
            return accumulated.description
        }
    }
    
    var result: Double? {
        get {
            return accumulated.value
        }
    }
}
