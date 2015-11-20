//
//  GameScene.swift
//  ZombieConga
//
//  Created by Daniel Dura Monge on 18/11/15.
//  Copyright (c) 2015 Daniel Dura Monge. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    var zombi:SKSpriteNode!
    var lastUpdateTime: NSTimeInterval = 0
    var dt: NSTimeInterval = 0
    let zombieMovePointsPerSec: CGFloat = 480.0
    var velocity = CGPoint.zero
    
    override func didMoveToView(view: SKView) {
  
        
        let background = SKSpriteNode(imageNamed: "background1")
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        
        background.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        background.zPosition = -1
        
        addChild(background)
        initZombi()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        

    }
   
    override func update(currentTime: CFTimeInterval) {
        moveSprite(zombi, velocity: CGPoint(x: zombieMovePointsPerSec, y: 0))
        if lastUpdateTime > 0{
            dt = currentTime - lastUpdateTime
        }else{
                dt = 0
        }
        lastUpdateTime = currentTime
            print("\(dt*1000) milliseconds since las update")
        
        
    }
    
    func initZombi(){
        
        zombi = SKSpriteNode(imageNamed: "zombie1")
        
        zombi.position = CGPoint(x: 400, y: 400)
        //zombi.setScale(2)
        addChild(zombi)
    }
    
    func moveSprite(sprite: SKSpriteNode, velocity: CGPoint){
        let amountToMove = CGPoint(x: velocity.x * CGFloat(dt),
                                   y: velocity.y * CGFloat(dt))
        
        print("Amout to move: \(amountToMove)")
        
        sprite.position = CGPoint(x: sprite.position.x + amountToMove.x,
                                  y: sprite.position.y + amountToMove.y)
    }
}
