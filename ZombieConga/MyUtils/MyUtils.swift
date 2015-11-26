//
//  MyUtils.swift
//  ZombieConga
//
//  Created by Daniel Dura Monge on 26/11/15.
//  Copyright © 2015 Daniel Dura Monge. All rights reserved.
//

import Foundation
import CoreGraphics

func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func += (inout left: CGPoint, right:CGPoint) {
    left = left + right
}
