//
//  GraphViewController.swift
//  Calculator
//
//  Created by Kevin Pfefferle on 6/4/16.
//  Copyright © 2016 Kevin Pfefferle. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController {

    var program: CalculatorBrain.PropertyList = [] { didSet { updateUI() } }

    @IBOutlet weak var graphView: GraphView! {
        didSet {
            graphView.addGestureRecognizer(UIPinchGestureRecognizer(
                target: graphView,
                action: #selector(GraphView.changeScale(_:))
            ))
            updateUI()
        }
    }

    private func updateUI() {
        if graphView != nil {
            graphView.program = program
        }
    }

}
