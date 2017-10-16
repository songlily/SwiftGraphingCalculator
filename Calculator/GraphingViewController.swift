//
//  GraphingViewController.swift
//  Graphing
//
//  Created by Lily Song on 2017-10-10.
//  Copyright © 2017 Lily Song. All rights reserved.
//

import UIKit

class GraphingViewController: UIViewController {
    
    @IBOutlet weak var graphLabel: UILabel!
    
    var graphText: String! 
    
    @IBOutlet weak var graphingView: GraphingView! {
        didSet {
            //pinching - GraphingView
            let pinch = #selector(graphingView.changeScale(byReactingTo:))
            let pinchRecognizer = UIPinchGestureRecognizer(target: graphingView, action: pinch)
            graphingView.addGestureRecognizer(pinchRecognizer)
            
            //panning - GraphingView
            let pan = #selector(graphingView.moveGraph(byReactingTo:))       //move graph
            let panRecognizer = UIPanGestureRecognizer(target: graphingView, action: pan)
            graphingView.addGestureRecognizer(panRecognizer)
            
            //double tapping - GraphingView
            let tap = #selector(graphingView.moveOrigin(byReactingTo:))       //move origin
            let tapRecognizer = UITapGestureRecognizer(target: graphingView, action: tap)
            tapRecognizer.numberOfTapsRequired = 2
            graphingView.addGestureRecognizer(tapRecognizer)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        graphLabel.text = graphText
        
        graphingView.graphingVC = self
    }
    
    var functionWrapper: GetFunction!
    func getYValue (variable x: CGFloat) -> CGFloat? {
        if functionWrapper != nil {
            let result = functionWrapper.evaluate(with: Double(x))
            if result != nil {
                return -CGFloat(result!)                               //return neg value since drawing y-axis is flipped
            } else {
                return nil
            }
            
        } else {
            return nil
        }
    }

}

 
