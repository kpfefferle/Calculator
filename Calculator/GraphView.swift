//
//  GraphView.swift
//  Calculator
//
//  Created by Kevin Pfefferle on 6/5/16.
//  Copyright © 2016 Kevin Pfefferle. All rights reserved.
//

import UIKit

class GraphView: UIView {

    override func drawRect(rect: CGRect) {

        let origin = CGPoint(x: bounds.midX, y: bounds.midY)

        let axesDrawer = AxesDrawer(contentScaleFactor: contentScaleFactor)
        axesDrawer.drawAxesInRect(bounds, origin: origin, pointsPerUnit: contentScaleFactor)

    }

}
