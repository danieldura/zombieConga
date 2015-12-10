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
    var lastUpdateTime: NSTimeInterval = 0
    var dt: NSTimeInterval = 0
    let zombieMovePointsPerSec: CGFloat = 480.0
    var velocity = CGPoint.zero
    var lastPlayerPoint:CGPoint?
    let zombieRotateRadiansPerSec:CGFloat = 4.0 * pi
    
    let zombieAnimation: SKAction
    
    let catCollisionSound: SKAction = SKAction.playSoundFileNamed("hitCat.wav", waitForCompletion: false)
    let enemyCollisionSound: SKAction = SKAction.playSoundFileNamed("hitCatLady.wav", waitForCompletion: false)
    
    var invincible = false
    let catMovePointPerSec:CGFloat = 480.0
    
    
    
    override func didMoveToView(view: SKView) {
        let background = SKSpriteNode(imageNamed: "background1")
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        
        background.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        background.zPosition = -1
        
        addChild(background)
        
        initZombi()

        runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.runBlock(spawnEnemy),SKAction.waitForDuration(2.0)])))
        runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.runBlock(spawnCat),SKAction.waitForDuration(1.0)])))
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
            if let lastPlayerPoint = lastPlayerPoint{
            let diff = lastPlayerPoint - zombi.position
            if (diff.length() <= zombieMovePointsPerSec * CGFloat(dt)) {
                zombi.position = lastPlayerPoint
                velocity = CGPointZero
                stopZombieAnimation()
            }else{
                moveSprite(zombi, velocity: velocity)
                rotateSprite(zombi, direction: velocity,rotateRadianPerSec: zombieRotateRadiansPerSec)
            }
        }
        boundsCheckZombie()
        moveTrain()
    }
    
    override func didEvaluateActions() {
        checkCollisions()
    }
    
    func initZombi(){
        zombi = SKSpriteNode(imageNamed: "zombie1")
        zombi.zPosition = 100
        zombi.position = CGPoint(x: 400, y: 400)

        addChild(zombi)
    }
    
    func moveSprite(sprite: SKSpriteNode, velocity: CGPoint){
        let amountToMove = velocity * CGFloat(dt)
        sprite.position += amountToMove
    }

    func rotateSprite(sprite: SKSpriteNode, direction: CGPoint,
                            rotateRadianPerSec: CGFloat){
        let shortest = shortestAngleBetween(sprite.zRotation, angle2: velocity.angle)
        let amountToRotate = min(rotateRadianPerSec * CGFloat(dt), abs(shortest))
        sprite.zRotation += shortest.sign() * amountToRotate
    }

    
    func moveZombieToward(location:CGPoint){
        startZombieAnimation()
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
        
        var textures: [SKTexture] = []
        for i in 1...4{
            textures.append(SKTexture(imageNamed: "zombie\(i)"))
        }
        textures.append(textures[2])
        textures.append(textures[1])
        
        zombieAnimation = SKAction.animateWithTextures(textures, timePerFrame: 0.1)
        
        
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
        enemy.name = "enemy"
        enemy.position = CGPoint(x: size.width + enemy.size.width/2,
                                 y: CGFloat.random(
                                    min: CGRectGetMinY(playableRect) + enemy.size.height/2,
                                    max: CGRectGetMaxY(playableRect) - enemy.size.height/2))
        addChild(enemy)

        let actionMove = SKAction.moveToX(-enemy.size.width/2, duration:2.0)
        let actionRemove = SKAction.removeFromParent()
        enemy.runAction(SKAction.sequence([actionMove, actionRemove]))
    }
    
    func spawnCat(){
        let cat = SKSpriteNode(imageNamed: "cat")
        cat.name = "cat"
        cat.position = CGPoint(
            x: CGFloat.random(
                min: CGRectGetMinX(playableRect),
                max: CGRectGetMaxX(playableRect)),
            y: CGFloat.random(
                min: CGRectGetMinY(playableRect),
                max: CGRectGetMaxY(playableRect)))
        cat.setScale(0)
        addChild(cat)
        
        let appear = SKAction.scaleTo(1.0, duration: 0.5)
//        let wait = SKAction.waitForDuration(10.0)
        cat.zRotation = -pi / 16.0
        let leftWiggle = SKAction.rotateByAngle(pi/8.0, duration: 0.5)
        let rightWigle = leftWiggle.reversedAction()
        let fullWigle = SKAction.sequence([leftWiggle,rightWigle])
//        let wiggleWait = SKAction.repeatAction(fullWigle, count: 10)
        let scaleUp = SKAction.scaleBy(1.2, duration: 0.25)
        let scaleDown = scaleUp.reversedAction()
        let fullScale = SKAction.sequence([scaleUp,scaleDown,scaleUp,scaleDown])
        let group = SKAction.group([fullScale,fullWigle])
        let groupWait = SKAction.repeatAction(group, count: 10)
        
        let disappear = SKAction.scaleTo(0, duration: 0.5)
        let removeFromParent = SKAction.removeFromParent()
        let actions = [appear, groupWait, disappear, removeFromParent]
        cat.runAction(SKAction.sequence(actions))
    }
    func startZombieAnimation(){
        if zombi.actionForKey("animation") == nil {
            zombi.runAction(SKAction.repeatActionForever(zombieAnimation), withKey: "animation")
        }
    }
    func stopZombieAnimation(){
        zombi.removeActionForKey("animation")
    }
    
// MARK: Collision fuctions
    func zombieHitCat(cat: SKSpriteNode){
        runAction(catCollisionSound)
//        cat.removeFromParent()
        cat.name="train"
        cat.removeAllActions()
        let greenColor = SKAction.colorizeWithColor(SKColor.greenColor(), colorBlendFactor: 1.0, duration: 0.2)
        let scaleNormal = SKAction.scaleTo(1.0, duration: 0.5)
        
        let group = [greenColor,scaleNormal]
        cat.runAction(SKAction.sequence(group))
        
    }
    func zombieHitEnemy(enemy: SKSpriteNode){
        runAction(enemyCollisionSound)
        enemy.removeFromParent()
        
        invincible = true
        let blinkTimes = 10.0
        let duration = 10.0
        let blinkAction = SKAction.customActionWithDuration(duration){
            node, elapsedTime in
            let slice = duration / blinkTimes
            let remainder = Double(elapsedTime) % slice
            node.hidden = remainder > slice / 2
        }
        let setHidden = SKAction.runBlock(){
            self.zombi.hidden = false
            self.invincible = false
        }
        
        zombi.runAction(SKAction.sequence([blinkAction, setHidden]))
    }
    func checkCollisions(){
        var hitCats:[SKSpriteNode] = []
        enumerateChildNodesWithName("cat") {
            node, _ in
            let cat = node  as! SKSpriteNode
            if CGRectIntersectsRect(cat.frame, self.zombi.frame){
                hitCats.append(cat)
            }
        }
        for cat in hitCats{
            zombieHitCat(cat)
        }
        if invincible{
            return
        }
        
        var hitEnemies: [SKSpriteNode] = []
        enumerateChildNodesWithName("enemy"){
            node, _ in
            let enemy = node as! SKSpriteNode
            if CGRectIntersectsRect(
                CGRectInset(node.frame, 20, 20),
                self.zombi.frame)   {
                    hitEnemies.append(enemy)
            }
        }
        for enemy in hitEnemies{
                zombieHitEnemy(enemy)
        }
    }
    
    func moveTrain(){
        var targetPosition = zombi.position
        
        enumerateChildNodesWithName("train") {
            node, _ in
            if !node.hasActions(){
                let actionDuration = 0.3
                let offset = targetPosition - node.position
                let direcction = offset.normalized()
                let amountToMovePerSec = direcction * self.catMovePointPerSec
                let amountToMove = amountToMovePerSec * CGFloat(actionDuration)
                let moveAction = SKAction.moveByX(amountToMove.x,y:amountToMove.y, duration: actionDuration)
                node.runAction(moveAction)
                
            }
            targetPosition = node.position
        }
    
    
    }
}