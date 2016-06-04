//
//  GlobalSplitViewController.swift
//  Calculator
//
//  Created by Kevin Pfefferle on 6/4/16.
//  Copyright © 2016 Kevin Pfefferle. All rights reserved.
//

import UIKit

class GlobalSplitViewController: UISplitViewController, UISplitViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.delegate = self
    }

    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController: UIViewController, ontoPrimaryViewController primaryViewController: UIViewController) -> Bool {
        return true
    }

}
