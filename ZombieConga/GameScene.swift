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
    var lastUdateTime: NSTimeInterval = 0
    var dt: NSTimeInterval = 0
    
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
        zombi.position = CGPoint(x: zombi.position.x+8, y: zombi.position.y)
    }
    
    func initZombi(){
        
        zombi = SKSpriteNode(imageNamed: "zombie1")
        
        zombi.position = CGPoint(x: 400, y: 400)
        //zombi.setScale(2)
        addChild(zombi)
    }
}
