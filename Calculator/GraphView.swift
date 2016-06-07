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

    @IBInspectable
    var graphColor: UIColor = UIColor.redColor() { didSet { setNeedsDisplay() } }
    @IBInspectable
    var graphLine: CGFloat = 1.0 { didSet { setNeedsDisplay() } }
    @IBInspectable
    var scale: CGFloat = 50.0 { didSet { setNeedsDisplay() } }

    var graphingFunction: ((Double) -> Double?)? { didSet { setNeedsDisplay() } }

    private var setOrigin: CGPoint? { didSet { setNeedsDisplay() } }
    var origin: CGPoint {
        get {
            return setOrigin ?? CGPoint(x: bounds.midX, y: bounds.midY)
        }
        set {
            setOrigin = newValue
        }
    }

    func changeScale(recognizer: UIPinchGestureRecognizer) {
        switch recognizer.state {
        case .Changed, .Ended:
            scale *= recognizer.scale
            recognizer.scale = 1.0
        default:
            break
        }
    }

    func changeOrigin(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .Changed, .Ended:
            let translation = recognizer.translationInView(self)
            origin = CGPoint(x: origin.x + translation.x, y: origin.y + translation.y)
            recognizer.setTranslation(CGPointZero, inView: self)
        default:
            break
        }
    }

    func reset() {
        scale = 50.0
        origin = CGPoint(x: bounds.midX, y: bounds.midY)
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
        let xValue = valueForXCoordinate(xCoord)
        let yValue = graphingFunction?(xValue)
        return coordinateForYValue(yValue!)
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
