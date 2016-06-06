//
//  GraphView.swift
//  Calculator
//
//  Created by Kevin Pfefferle on 6/5/16.
//  Copyright © 2016 Kevin Pfefferle. All rights reserved.
//

import UIKit

@IBDesignable
class GraphView: UIView {

    private let brain = CalculatorBrain()

    @IBInspectable
    var graphColor: UIColor = .redColor()
    @IBInspectable
    var graphLine: CGFloat = 1.0
    @IBInspectable
    var scale: CGFloat = 50.0 // points per unit
    
    var origin: CGPoint {
        return CGPoint(x: bounds.midX, y: bounds.midY)
    }
    var program: CalculatorBrain.PropertyList {
        get {
            return brain.program
        }
        set {
            brain.program = newValue
        }
    }

    private func drawAxes() {
        let axesDrawer = AxesDrawer(contentScaleFactor: contentScaleFactor)
        axesDrawer.drawAxesInRect(bounds, origin: origin, pointsPerUnit: scale)
    }

    private func valueForXCoordinate(xCoord: CGFloat) -> Double {
        return Double((xCoord - origin.x) / scale)
    }

    private func coordinateForYValue(yValue: Double) -> CGFloat {
        return origin.y - (CGFloat(yValue) * scale)
    }

    private func yForX(xCoord: CGFloat) -> CGFloat {
        brain.variableValues["M"] = valueForXCoordinate(xCoord)
        return coordinateForYValue(brain.result)
    }

    private func drawGraph() {

        let path = UIBezierPath()
        var x = bounds.minX
        var y = yForX(x)
        path.moveToPoint(CGPoint(x: x, y: y))

        while x < bounds.maxX {

            let newX = x + (1 / contentScaleFactor)
            let newY = yForX(newX)

            if abs(newY - y) > max(bounds.width, bounds.height) {
                path.moveToPoint(CGPoint(x: newX, y: newY))
            } else {
                path.addLineToPoint(CGPoint(x: newX, y: newY))
            }

            x = newX
            y = newY
        }

        graphColor.setStroke()
        path.lineWidth = graphLine
        path.stroke()
    }

    override func drawRect(rect: CGRect) {
        drawAxes()
        drawGraph()
    }

}
