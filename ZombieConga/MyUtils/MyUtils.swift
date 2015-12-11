//
//  MyUtils.swift
//  ZombieConga
//
//  Created by Daniel Dura Monge on 26/11/15.
//  Copyright © 2015 Daniel Dura Monge. All rights reserved.
//

import Foundation
import CoreGraphics
import AVFoundation

var backgroundMusicPlayer: AVAudioPlayer!


func playBackgroundMusic(filename: String){
    let resourceURL = NSBundle.mainBundle().URLForResource(
        filename, withExtension: nil)
    guard let url = resourceURL else{
        print("Could not find file: \(filename)")
        return
    }
    
    do {
        try backgroundMusicPlayer = AVAudioPlayer(contentsOfURL: url)
        backgroundMusicPlayer.numberOfLoops = -1
        backgroundMusicPlayer.prepareToPlay()
        backgroundMusicPlayer.play()
    } catch{
        print("Could not create audio player!")
        return
    }
}

func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func += (inout left: CGPoint, right:CGPoint) {
    left = left + right
}


func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y:  left.y - right.y)
    
    
}
func -= (inout left: CGPoint, right: CGPoint) {
    left = left - right
}


func * (left: CGPoint, right:CGPoint) -> CGPoint {
    return CGPoint(x: left.x * right.x, y: left.y * right.y)
}

func *= (inout left: CGPoint, right: CGPoint) {
    left = left * right
}

func *  (point: CGPoint, scalar: CGFloat) -> CGPoint{
    return CGPoint(x:point.x * scalar, y:point.y * scalar)
}
func *= (inout point: CGPoint, scalar: CGFloat){
    point = point * scalar
}

func / (left: CGPoint , right : CGPoint) -> CGPoint {
    return CGPoint(x: left.x / right.x, y: left.y / right.y)
}

func /= (inout left: CGPoint, right: CGPoint){
    left = left /  right
    
}
func / (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

func /= (inout point: CGPoint, scalar : CGFloat){
    point = point / scalar
}

#if !(arch(x86_62) || arch(arm64))
    func atan2(y:CGFloat, x:CGFloat) -> CGFloat {
        return CGFloat(atan2f(Float(y), Float(x)))
}

    func sqrt(a: CGFloat) -> CGFloat{
        return CGFloat(sqrtf(Float(a)))
}
#endif

extension CGPoint{
    func length() -> CGFloat {
        return sqrt(x*x + y*y)
    }
    func normalized() -> CGPoint {
        return self / length()
    }
    var angle: CGFloat {
        return atan2(y, x)
    }
}

// MARK: Make the rotation zombie more smoothly to be realist
let pi = CGFloat(M_PI)
    func shortestAngleBetween(angle1: CGFloat,
        angle2: CGFloat) -> CGFloat{
            
        let twoPi = pi * 2.0
        var angle = (angle2 - angle1) % twoPi
        if (angle >= pi){
            angle = angle - twoPi
        }
            if (angle <= -pi){
                angle = angle + twoPi
            }
            return angle
    }



extension CGFloat{
    func sign() -> CGFloat {
    return (self >= 0.0) ? 1.0 : -1.0
    }
}
// MARK: -
// MARK: RANDOM FUNCTIONS
    
extension CGFloat{
        static func random() -> CGFloat{
            return CGFloat(Float(arc4random()) / Float(UInt32.max))
        }
    static func random(min min: CGFloat, max: CGFloat) -> CGFloat {
        assert(min < max)
        return CGFloat.random() * (max - min) + min
    }
}
























