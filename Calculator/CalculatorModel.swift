//
//  CalculatorModel.swift
//  Calculator
//
//  Created by Lily Song on 2017-09-21.
//  Copyright © 2017 Lily Song. All rights reserved.
//

import Foundation

func fact(n: Double) -> Double {                                            // factorial function
    if (n >= 0) && (Double(Int(n)) == n) {
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
    
    //private var accumulated: (value: Double?, description: String) = (nil, " ")
    //private var operand: String?
    //private var lastUnary = false                                                   //checks if last operation was a unary operation
    
    private var externalExpressionArray = [String?] ()             //array components of description/input
    

    private enum Operation {
        case constant(Double)
        case unaryOperation((Double) -> Double, (String) -> String)
        case binaryOperation((Double, Double) -> Double, (Void) -> String)                              //(String, String) -> String)
        case equals
        case clear
        //case undo
    }
    
    private var operations: [String:Operation] = [
        "C": Operation.clear,

        "+": Operation.binaryOperation(+, {" + "}),
        "−": Operation.binaryOperation(-, {" - "}),
        "×": Operation.binaryOperation(*, {" × "}),
        "÷": Operation.binaryOperation(/, {" ÷ "}),
        "=": Operation.equals,
        
        "±": Operation.unaryOperation({-$0}, {" -(\($0))"}),                       //before
        "x²": Operation.unaryOperation({$0*$0}, {" (\($0))²"}),                       //after
        "√": Operation.unaryOperation(sqrt, {" √(\($0))"}),                       //before
        "!": Operation.unaryOperation(fact, {" \($0)!"}),                        //after
        
        "%": Operation.unaryOperation({$0/100}, {" \($0)%"}),                       //after
        "π": Operation.constant(Double.pi),
        "e": Operation.constant(M_E),
        "ln": Operation.unaryOperation(log, {" ln(\($0))"}),                       //before

        "sin": Operation.unaryOperation(sin, {" sin(\($0))"}),                       //before
        "cos": Operation.unaryOperation(cos, {" cos(\($0))"}),
        "tan": Operation.unaryOperation(tan, {" tan(\($0))"}),
        
        //"←": Operation.undo
    ]
    
    mutating func performOperation (_ symbol: String) {
        externalExpressionArray.append(symbol)
    }
    
    mutating func setOperand (_ operand: Double) {
        externalExpressionArray.append("\(operand)")
    }
    
    mutating func setOperand (variable named: String) {
        externalExpressionArray.append(named)
    }
    
    mutating func undo () {
        if !externalExpressionArray.isEmpty {
            let undid = externalExpressionArray.dropLast()
            externalExpressionArray = Array(undid)
        }
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
        return evaluate().isPending
    }

    var description: String? {                                                    //lists what user has typed
        get {
            return evaluate().description
        }
    }
    
    var result: Double? {
        get {
            return evaluate().result
        }
    }
    
    
            //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
    
    // expression array: ["7", "+", "9", "√"]
    
    
    func evaluate(using variables: [String: Double]? = nil)
        -> (result: Double?, isPending: Bool, description: String) {
        //
        
        var expressionArray = externalExpressionArray             //array components of description/input
        var result: Double?
        var description = " "
        var letter: String? = nil
        var lastUnary = false
        var lastVar = false
        
        var pendingBinaryOperation: PendingBinOp?
        var isPending : Bool {
            return pendingBinaryOperation != nil
        }
            
        func stringResult() -> String {
            if Double(Int(result!)) == result! {
                return String(Int(result!))
            } else {
                return String(result!)
            }
        }
        
        func setOperand(_ operand: Double) {
            if description.contains("=") || lastUnary || lastVar {                                         // if already contains complete equation, clear
                description = " "
            }
            
            result = operand
            description = description.replacingOccurrences(of: " ...", with: "")          //remove ellipsis
            description += stringResult()
        }
        
        func setOperand (variable named: String) {
            if variables?[named] != nil {
                result = variables![named]
            } else {
                result = 0
            }
            if description.contains("=") || lastUnary {                                         // if already contains complete equation, clear
                description = " "
            }
            description = description.replacingOccurrences(of: " ...", with: "")          //remove ellipsis
            description += named
            if isPending {
                description += (" ...")
            }
            letter = named
            lastVar = true
        }
        
        func performOperation (_ symbol: String) {
            
            let descriptionHasEquals = description.contains("=")
            description = description.replacingOccurrences(of: " ...", with: "")          //remove ellipsis
            
            if let operation = operations[symbol]  {
                switch operation {
                    
                case .constant(let value):
                    if (lastUnary || descriptionHasEquals || lastVar) {                                          //if last operation was a unary operation, clear description
                        description = " "
                    }
                    result = value
                    description += "\(symbol)"
                    
                case .unaryOperation (let function, let descriptionFunction):
                    if lastUnary {
                        description = " "
                    }
                    description = description.components(separatedBy: " ").dropLast().joined(separator: " ")
                    if result != nil {
                        
                        if descriptionHasEquals {                                                   //how to append to expressionArray??
                            description = descriptionFunction(description)
                        } else if letter != nil {
                            description += descriptionFunction(letter!)
                        } else {
                            description += descriptionFunction(stringResult())
                        }
                        result = function(result!)
                    }
                    lastUnary = true
                    lastVar = false
                    
                case .binaryOperation (let function, let descriptionFunction):
                    if descriptionHasEquals {                                         // if already contains complete equation, clear description
                        description = description.components(separatedBy: " ").dropLast().joined(separator: " ")
                    }
                    
                    if result != nil {
                        //first runthrough, save function as function, result as value
                        //second+ runthough, use saved function+value and evaluate with enw result, (save function as function, result as value)
                        if isPending {
                            result = (pendingBinaryOperation!.perform(with: result!))
                        }
                        pendingBinaryOperation = PendingBinOp (function: function, firstOperand: result!)
                        
                        result = nil
                        description += descriptionFunction()
                        lastUnary = false
                        lastVar = false
                    }
                    
                case .equals:
                    if result != nil && !descriptionHasEquals {
                        if isPending {
                            result = pendingBinaryOperation!.perform(with: result!)
                            pendingBinaryOperation = nil
                        }
                        description += (" =")
                    }
                    lastUnary = false
                    lastVar = false
                    
                case .clear:                                                        //clears all values or returns to default
                    result = 0
                    description = " "
                    pendingBinaryOperation = nil
                    lastUnary = false
                    lastVar = false
                    letter = nil
                //case .undo:
                    //undo()
                }
            }
            
            if isPending {
                description += (" ...")
            }
        }
        
        for item in expressionArray {
            if Double(item!) != nil {
                setOperand(Double(item!)!)
            } else if operations[item!] != nil {
                performOperation(item!)
            } else {
                setOperand(variable: item!)
            }
        }
        
        //
        return (result, isPending, description)
    }
    
    
                //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
    
    /*
    private enum Expression {
        case operand (Double)
        case variable (String)          //((String) -> Double)
        indirect case operation (Expression, Expression?)
    }
     */

}
