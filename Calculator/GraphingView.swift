//
//  GraphingView.swift
//  Graphing
//
//  Created by Lily Song on 2017-10-10.
//  Copyright © 2017 Lily Song. All rights reserved.
//

import UIKit

@IBDesignable
class GraphingView: UIView {
    
    // Must be generic + reusable
    // Takes an x vs y function
    // and graphs it
    
    @IBInspectable
    var scale: CGFloat = 25 { didSet { setNeedsDisplay() } }
    var origin: CGPoint?    { didSet { setNeedsDisplay() } }                         //could be not on screen == nil
    var axes = AxesDrawer()
    var lineWidth: CGFloat = 3.0
    var color: UIColor = UIColor.blue
    
    //var graphingVC: GraphingViewController!
    var getYValue: ((Double) -> Double?)!
    private func getYValueAsCGFloat(_ x : CGFloat) -> CGFloat? {
        if getYValue != nil {
            let result = getYValue(Double(x))
            if result != nil {
                return -CGFloat(result!)                               //return neg value since drawing y-axis is flipped
            } else {
                return nil
            }
            
        } else {
            return nil
        }
    }
    
    // Gesture functions
    
    func changeScale (byReactingTo pinchRecognizer: UIPinchGestureRecognizer) {                     //pinch to zoom in/out of graph
        switch pinchRecognizer.state {
        case .changed, .ended:
            scale *= pinchRecognizer.scale
            axes.contentScaleFactor = scale
            pinchRecognizer.scale = 1
        default:
            break
        }
    }
    
    func moveGraph (byReactingTo panRecognizer: UIPanGestureRecognizer) {                           //pan and translate origin by amount panned
        //translate origin
        if panRecognizer.state == .began || panRecognizer.state == .changed {
            let translation = panRecognizer.translation(in: self)
            origin = CGPoint(x: origin!.x + translation.x,
                             y: origin!.y + translation.y)
            panRecognizer.setTranslation(CGPoint.zero, in: self)
        }
    }
    
    func moveOrigin (byReactingTo tapRecognizer: UITapGestureRecognizer) {                          //tap to set origin to tapped place
        if tapRecognizer.state == .ended {
            let tappedPoint = tapRecognizer.location(in: self)
            origin = tappedPoint
        }
    }
    
    //Drawing functions    
    
    private func drawFunction () -> UIBezierPath {
        let path = UIBezierPath()
        
        //self.bounds.width (points) * UIScreen.main.scale (scale in pixels/points) = pixels
        //1 unit = (scale*UIScreen.main.scale); UIScreen.main.scale = 2.0
        let horizontalPixels = self.bounds.width * UIScreen.main.scale                    //calculate number of horizontal pixels
        let xFactor = 1/scale
        
        path.move(to: CGPoint(x: -1, y: origin!.y))
        //for xPixel in CGFloat(0) ... horizontalPixels {
        for xPixel in stride(from: -1, to: horizontalPixels, by: +1 as CGFloat) {     //0 as CGFloat
            if let yPixel = getYValueAsCGFloat(xFactor * (xPixel - origin!.x)) {
                path.addLine(to: CGPoint (x: xPixel, y: scale * yPixel + origin!.y))
            }
            
        }
        path.lineWidth = lineWidth
        return path
    }
    
    override func draw (_ rect: CGRect) {
        if origin == nil {
            origin = CGPoint(x: bounds.midX, y: bounds.midY)
        }
        color.set()
        
        axes.contentScaleFactor = scale
        axes.drawAxes(in: rect, origin: origin!, pointsPerUnit: scale)
        
        drawFunction().stroke()
    }
    
}
