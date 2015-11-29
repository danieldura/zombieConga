//
//  GameScene.swift
//  ZombieConga
//
//  Created by Daniel Dura Monge on 18/11/15.
//  Copyright (c) 2015 Daniel Dura Monge. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    let playableRect :CGRect
    var zombi:SKSpriteNode!
//    var enemy:SKSpriteNode!

    var lastUpdateTime: NSTimeInterval = 0
    var dt: NSTimeInterval = 0
    let zombieMovePointsPerSec: CGFloat = 480.0
    var velocity = CGPoint.zero
    var lastPlayerPoint:CGPoint?
    let zombieRotateRadiansPerSec:CGFloat = 4.0 * pi
    
    override func didMoveToView(view: SKView) {
        let background = SKSpriteNode(imageNamed: "background1")
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        
        background.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        background.zPosition = -1
        
        addChild(background)
        
        initZombi()
        spawnEnemy()
        DEBUG_PlayableArea()      
    }
    func sceneTouched(touchLocation:CGPoint){
        lastPlayerPoint = touchLocation
        moveZombieToward(touchLocation)
    }
    
    override func touchesBegan(touches: Set<UITouch>,
        withEvent event: UIEvent?) {
            guard let touch = touches.first else{
                return
            }
            let touchLocation = touch.locationInNode(self)
            sceneTouched(touchLocation)
    }
    override func touchesMoved(touches: Set<UITouch>,
        withEvent event: UIEvent?) {
        guard let touch = touches.first else{
            return
        }
        let touchLocation = touch.locationInNode(self)
        sceneTouched(touchLocation)
    }

    override func update(currentTime: CFTimeInterval) {
        
        if lastUpdateTime > 0{
            dt = currentTime - lastUpdateTime
        }else{
            dt = 0
        }
        lastUpdateTime = currentTime
            print("\(dt*1000) milliseconds since las update")
        if let lastPlayerPoint = lastPlayerPoint{
            let diff = lastPlayerPoint - zombi.position
            if (diff.length() <= zombieMovePointsPerSec * CGFloat(dt)) {
                zombi.position = lastPlayerPoint
                velocity = CGPointZero
            }else{
                moveSprite(zombi, velocity: velocity)
                rotateSprite(zombi, direction: velocity,rotateRadianPerSec: zombieRotateRadiansPerSec)
            }
        }
        boundsCheckZombie()        
        }
    
    func initZombi(){
        zombi = SKSpriteNode(imageNamed: "zombie1")
        
        zombi.position = CGPoint(x: 400, y: 400)
        //zombi.setScale(2)
        addChild(zombi)
    }
    
//    func moveSprite(sprite: SKSpriteNode, velocity: CGPoint){
//        let amountToMove = CGPoint(x: velocity.x * CGFloat(dt),
//                                   y: velocity.y * CGFloat(dt))
//        
//        print("Amout to move: \(amountToMove)")
//        
//        sprite.position = CGPoint(x: sprite.position.x + amountToMove.x,
//                                  y: sprite.position.y + amountToMove.y)
//    }
    
    func moveSprite(sprite: SKSpriteNode, velocity: CGPoint){
        let amountToMove = velocity * CGFloat(dt)
        sprite.position += amountToMove
    }
//    func rotateSprite(sprite: SKSpriteNode, direction: CGPoint){
//        sprite.zRotation = CGFloat(
//            atan2(Double(direction.y), Double(direction.x)))
//    }
    func rotateSprite(sprite: SKSpriteNode, direction: CGPoint,
                            rotateRadianPerSec: CGFloat){
        let shortest = shortestAngleBetween(sprite.zRotation, angle2: velocity.angle)
        let amountToRotate = min(rotateRadianPerSec * CGFloat(dt), abs(shortest))
        sprite.zRotation += shortest.sign() * amountToRotate
    }
//    func moveZombieToward(location:CGPoint){
//        let offset = CGPoint(x: location.x - zombi.position.x,
//                             y: location.y - zombi.position.y)
//        let length = sqrt(Double(offset.x * offset.x + offset.y * offset.y))
//        let direction = CGPoint(x: offset.x / CGFloat(length),
//                                y: offset.y / CGFloat(length))
//        velocity = CGPoint(x: direction.x * zombieMovePointsPerSec,
//                           y: direction.y * zombieMovePointsPerSec)
//    }
    
    func moveZombieToward(location:CGPoint){
        let offset = location - zombi.position
        let length = sqrt(Double(offset.x * offset.x + offset.y * offset.y))
        let direction = offset / CGFloat(length)
        velocity = direction * zombieMovePointsPerSec
    }
    
    func boundsCheckZombie(){
        let bottomLeft = CGPoint(x: 0, y: CGRectGetMinY(playableRect))
        let topRight = CGPoint(x: size.width, y: CGRectGetMaxY(playableRect)    )
        
        if zombi.position.x <= bottomLeft.x {
            zombi.position.x = bottomLeft.x
            velocity.x = -velocity.x
        }
        if zombi.position.x >= topRight.x {
            zombi.position.x = topRight.x
            velocity.x = -velocity.x
                    }
        if zombi.position.y <= bottomLeft.y {
            zombi.position.y = bottomLeft.y
            velocity.y = -velocity.y
        }
        if zombi.position.y >= topRight.y{
            zombi.position.y = topRight.y
            velocity.y = -velocity.y
        }
    }
    
    override init(size:CGSize) {
        let maxAspectRatio:CGFloat = 16.0/9.0
        let playableHeight = size.width / maxAspectRatio
        let playableMargin = (size.height-playableHeight)/2.0
        playableRect = CGRect(x:0, y: playableMargin,width: size.width, height: playableHeight)
        super.init(size:size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func DEBUG_PlayableArea(){
    let shape = SKShapeNode()
    let path = CGPathCreateMutable()
        CGPathAddRect(path,nil, playableRect)
        shape.path = path
        shape.strokeColor = SKColor.redColor()
        shape.lineWidth = 4.0
        addChild(shape)
    }
    
    func spawnEnemy() {
        let enemy = SKSpriteNode(imageNamed: "enemy")
        enemy.position = CGPoint(x: size.width + enemy.size.width/2,
                                 y: size.height/2)
        addChild(enemy)
        let actionMove = SKAction.moveTo(
            CGPoint(x: -enemy.size.width/2,
                    y: enemy.position.y), duration: 2.0)
        enemy.runAction(actionMove)
    }
}
