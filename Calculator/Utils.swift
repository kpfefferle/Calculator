//
//  Utils.swift
//  Calculator
//
//  Created by Kevin Pfefferle on 5/29/16.
//  Copyright © 2016 Kevin Pfefferle. All rights reserved.
//

import Foundation

extension String {
    func trim() -> String {
        return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    }
}
