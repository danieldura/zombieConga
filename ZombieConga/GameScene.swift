//
//  GameScene.swift
//  ZombieConga
//
//  Created by Daniel Dura Monge on 18/11/15.
//  Copyright (c) 2015 Daniel Dura Monge. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    var lives = 5
    var gameOver = false
    let playableRect :CGRect
    var zombi:SKSpriteNode!
    var lastUpdateTime: TimeInterval = 0
    var dt: TimeInterval = 0
    let zombieMovePointsPerSec: CGFloat = 480.0
    var velocity = CGPoint.zero
    var lastPlayerPoint:CGPoint?
    let zombieRotateRadiansPerSec:CGFloat = 4.0 * pi
    
    let zombieAnimation: SKAction
    
    let catCollisionSound: SKAction = SKAction.playSoundFileNamed("hitCat.wav", waitForCompletion: false)
    let enemyCollisionSound: SKAction = SKAction.playSoundFileNamed("hitCatLady.wav", waitForCompletion: false)
    
    var invincible = false
    let catMovePointPerSec:CGFloat = 480.0
    let livesLabel = SKLabelNode(fontNamed: "Chalkduster")
    let catsLabel = SKLabelNode(fontNamed: "Chalkduster")
    
    
    // MARK: CAMERA
    let cameraNode = SKCameraNode()
    let cameraMovePointsPerSec: CGFloat = 200.0
    var cameraRect : CGRect {
        return CGRect(
            x: getCameraPosition().x - size.width/2
                + (size.width - playableRect.width)/2,
            y: getCameraPosition().y - size.height/2
                + (size.height - playableRect.height)/2,
            width: playableRect.width,
            height: playableRect.height)
    }
    
    override func didMove(to view: SKView) {
        playBackgroundMusic("backgroundMusic.mp3")
        for i in 0...1{
            let background = backgroundNode()
            background.position = CGPoint(x: CGFloat(i) * background.size.width, y:0)
            background.anchorPoint = CGPoint.zero
            background.zPosition = -1
            background.name = "background"
            addChild(background)
            print("bucle: ",i)
        }
   
        initZombi()

        run(SKAction.repeatForever(SKAction.sequence([SKAction.run(spawnEnemy),SKAction.wait(forDuration: 2.0)])))
        run(SKAction.repeatForever(SKAction.sequence([SKAction.run(spawnCat),SKAction.wait(forDuration: 1.0)])))
        addChild(cameraNode)
        camera = cameraNode
        setCameraPosition(CGPoint(x: size.width/2, y:size.height/2))
        
        livesLabel.text = "Lives: \(lives)"
        livesLabel.fontColor = SKColor.black
        livesLabel.fontSize = 100
        livesLabel.zPosition = 100
        livesLabel.horizontalAlignmentMode = .left
        livesLabel.verticalAlignmentMode = .bottom
        livesLabel.position = CGPoint(
            x: -playableRect.size.width/2 + CGFloat(20),
            y: -playableRect.size.height/2 + CGFloat(20) + overlapAmount()/2)
        cameraNode.addChild(livesLabel)
        
        catsLabel.text = "Cats:"
        catsLabel.fontColor = SKColor.black
        catsLabel.fontSize = 100
        catsLabel.zPosition = 100
        catsLabel.horizontalAlignmentMode = .right
        catsLabel.verticalAlignmentMode = .bottom
        catsLabel.position = CGPoint(
            x: playableRect.width/2 - CGFloat(20),
            y: -playableRect.size.height/2 + CGFloat(20) + overlapAmount()/2)
        
        print("posicion",catsLabel.position)
        cameraNode.addChild(catsLabel)
        
    }
    func sceneTouched(_ touchLocation:CGPoint){
        lastPlayerPoint = touchLocation
        moveZombieToward(touchLocation)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>,
        with event: UIEvent?) {
            guard let touch = touches.first else{
                return
            }
            let touchLocation = touch.location(in: self)
            sceneTouched(touchLocation)
    }
    override func touchesMoved(_ touches: Set<UITouch>,
        with event: UIEvent?) {
        guard let touch = touches.first else{
            return
        }
        let touchLocation = touch.location(in: self)
        sceneTouched(touchLocation)
    }

    override func update(_ currentTime: TimeInterval) {
        
        if lastUpdateTime > 0{
            dt = currentTime - lastUpdateTime
        }else{
            dt = 0
        }
        lastUpdateTime = currentTime
//            if let lastPlayerPoint = lastPlayerPoint{
//            let diff = lastPlayerPoint - zombi.position
//            if (diff.length() <= zombieMovePointsPerSec * CGFloat(dt)) {
//                zombi.position = lastPlayerPoint
//                velocity = CGPointZero
//                stopZombieAnimation()
//            }else{
                moveSprite(zombi, velocity: velocity)
                rotateSprite(zombi, direction: velocity,rotateRadianPerSec: zombieRotateRadiansPerSec)
//            }
//        }
        boundsCheckZombie()
        moveTrain()
        moveCamera()
        
        if lives <= 0 && !gameOver {
            gameOver = true
            print("HAS PERDIDO·")
            backgroundMusicPlayer.stop()
            
            let gameOverScene = GameOverScene(size: size, won: false)
            gameOverScene.scaleMode = scaleMode
            
            let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
            
            view?.presentScene(gameOverScene, transition: reveal)
        }
        
//        cameraNode.position = zombi.position
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
    
    func moveSprite(_ sprite: SKSpriteNode, velocity: CGPoint){
        let amountToMove = velocity * CGFloat(dt)
        sprite.position += amountToMove
    }

    func rotateSprite(_ sprite: SKSpriteNode, direction: CGPoint,
                            rotateRadianPerSec: CGFloat){
        let shortest = shortestAngleBetween(sprite.zRotation, angle2: velocity.angle)
        let amountToRotate = min(rotateRadianPerSec * CGFloat(dt), abs(shortest))
        sprite.zRotation += shortest.sign() * amountToRotate
    }

    
    func moveZombieToward(_ location:CGPoint){
        startZombieAnimation()
        let offset = location - zombi.position
        let length = sqrt(Double(offset.x * offset.x + offset.y * offset.y))
        let direction = offset / CGFloat(length)
        velocity = direction * zombieMovePointsPerSec
    }
    
    func boundsCheckZombie(){
        let bottomLeft = CGPoint(x: cameraRect.minX,
            y: cameraRect.minY)
        let topRight = CGPoint(x: cameraRect.maxX,
            y: cameraRect.maxY)
        
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
        
        zombieAnimation = SKAction.animate(with: textures, timePerFrame: 0.1)
        
        
        super.init(size:size)
        
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func spawnEnemy() {
        let enemy = SKSpriteNode(imageNamed: "enemy")
        enemy.name = "enemy"
        enemy.position = CGPoint(x: cameraRect.maxX + enemy.size.width/2,
                                 y: CGFloat.random(
                                    min: cameraRect.minY + enemy.size.height/2,
                                    max: cameraRect.maxY - enemy.size.height/2))
        addChild(enemy)

//        let actionMove = SKAction.moveToX(-enemy.size.width/2, duration:2.0)
//        let actionMove =SKAction.moveByX(-size.width-enemy.size.width*2, y: 0, duration: 2.0)

        let actionMove = SKAction.moveBy(x: -size.width-enemy.size.width*2, y: 0, duration: 2.0)
        let actionRemove = SKAction.removeFromParent()
        enemy.run(SKAction.sequence([actionMove, actionRemove]))
    }
    
    func spawnCat(){
        let cat = SKSpriteNode(imageNamed: "cat")
        cat.name = "cat"
        cat.position = CGPoint(
            x: CGFloat.random(
                min: cameraRect.minX,
                max: cameraRect.maxX),
            y: CGFloat.random(
                min: cameraRect.minY,
                max: cameraRect.maxY))
        cat.setScale(0)
        addChild(cat)
        
        let appear = SKAction.scale(to: 1.0, duration: 0.5)
//        let wait = SKAction.waitForDuration(10.0)
        cat.zRotation = -pi / 16.0
        let leftWiggle = SKAction.rotate(byAngle: pi/8.0, duration: 0.5)
        let rightWigle = leftWiggle.reversed()
        let fullWigle = SKAction.sequence([leftWiggle,rightWigle])
//        let wiggleWait = SKAction.repeatAction(fullWigle, count: 10)
        let scaleUp = SKAction.scale(by: 1.2, duration: 0.25)
        let scaleDown = scaleUp.reversed()
        let fullScale = SKAction.sequence([scaleUp,scaleDown,scaleUp,scaleDown])
        let group = SKAction.group([fullScale,fullWigle])
        let groupWait = SKAction.repeat(group, count: 10)
        
        let disappear = SKAction.scale(to: 0, duration: 0.5)
        let removeFromParent = SKAction.removeFromParent()
        let actions = [appear, groupWait, disappear, removeFromParent]
        cat.run(SKAction.sequence(actions))
    }
    func startZombieAnimation(){
        if zombi.action(forKey: "animation") == nil {
            zombi.run(SKAction.repeatForever(zombieAnimation), withKey: "animation")
        }
    }
    func stopZombieAnimation(){
        zombi.removeAction(forKey: "animation")
    }
    
// MARK: Collision fuctions
    func zombieHitCat(_ cat: SKSpriteNode){
        run(catCollisionSound)
//        cat.removeFromParent()
        cat.name="train"
        cat.removeAllActions()
        let greenColor = SKAction.colorize(with: SKColor.green, colorBlendFactor: 1.0, duration: 0.2)
        let scaleNormal = SKAction.scale(to: 1.0, duration: 0.5)
        
        let group = [greenColor,scaleNormal]
        cat.run(SKAction.sequence(group))
        
    }
    func zombieHitEnemy(_ enemy: SKSpriteNode){
        run(enemyCollisionSound)
        loseCats()
        lives -= 1
        enemy.removeFromParent()
        
        invincible = true
        let blinkTimes = 10.0
        let duration = 10.0
        let blinkAction = SKAction.customAction(withDuration: duration){
            node, elapsedTime in
            let slice = duration / blinkTimes
            let remainder = Double(elapsedTime).truncatingRemainder(dividingBy: slice)
            node.isHidden = remainder > slice / 2
        }
        let setHidden = SKAction.run(){
            self.zombi.isHidden = false
            self.invincible = false
        }
        
        zombi.run(SKAction.sequence([blinkAction, setHidden]))
    }
    func checkCollisions(){
        var hitCats:[SKSpriteNode] = []
        enumerateChildNodes(withName: "cat") {
            node, _ in
            let cat = node  as! SKSpriteNode
            if cat.frame.intersects(self.zombi.frame){
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
        enumerateChildNodes(withName: "enemy"){
            node, _ in
            let enemy = node as! SKSpriteNode
            if node.frame.insetBy(dx: 20, dy: 20).intersects(self.zombi.frame)   {
                    hitEnemies.append(enemy)
            }
        }
        for enemy in hitEnemies{
                zombieHitEnemy(enemy)
        }
    }
    
    func moveTrain(){
        var targetPosition = zombi.position
        var trainCount = 0
        enumerateChildNodes(withName: "train") {node, stop in
            trainCount += 1

            if !node.hasActions(){
                let actionDuration = 0.3
                let offset = targetPosition - node.position
                let direcction = offset.normalized()
                let amountToMovePerSec = direcction * self.catMovePointPerSec
                let amountToMove = amountToMovePerSec * CGFloat(actionDuration)
                let moveAction = SKAction.moveBy(x: amountToMove.x,y:amountToMove.y, duration: actionDuration)
                node.run(moveAction)
                
            }
            targetPosition = node.position
        }
        if trainCount >= 15 && !gameOver {
            gameOver = true
            print("Has ganado")
            backgroundMusicPlayer.stop()
            
            let gameOverScene = GameOverScene(size: size, won: true)
            gameOverScene.scaleMode = scaleMode
            let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
            
            view?.presentScene(gameOverScene, transition: reveal)
            
        }
    livesLabel.text = "Lives: \(lives)"
    self.catsLabel.text = "Cats: \(trainCount)"
    }
    
    
  // MARK: -

    func loseCats(){
        var loseCount = 0
        
        enumerateChildNodes(withName: "train"){ node, stop in
            var randomSpot = node.position
            randomSpot.x += CGFloat.random(min: -100, max: 100)
            randomSpot.y += CGFloat.random(min: -100, max: 100)
            
            node.name=""
            node.run(
                SKAction.sequence([
                    SKAction.group([
                        SKAction.rotate(byAngle: pi*4, duration: 1.0),
                        SKAction.move(to: randomSpot,duration: 1.0),
                        SKAction.scale(to: 0, duration: 1.0)
                    ]),
                    SKAction.removeFromParent()
                ]))
            loseCount += 1
            if loseCount >= 2{
                stop.pointee = true
            }
        }
    }
    
    // MARK: CAMERA METHODS
    func overlapAmount() -> CGFloat {
        guard let view = self.view else {
            return 0
        }
        let scale = view.bounds.size.width / self.size.width
        let scaleHeight = self.size.height * scale
        let scaledOverlap = scaleHeight - view.bounds.size.height
        return scaledOverlap / scale
    }
    func getCameraPosition() -> CGPoint {
        return CGPoint(x: cameraNode.position.x, y: cameraNode.position.y + overlapAmount()/2)
        
    }
    
    func setCameraPosition(_ position: CGPoint) {
        cameraNode.position = CGPoint(x: position.x, y: position.y - overlapAmount()/2)
    }

    func moveCamera(){
        let backgroundVelocity = CGPoint(x: cameraMovePointsPerSec, y: 0)
        let amountToMove = backgroundVelocity * CGFloat(dt)
        cameraNode.position += amountToMove
        
        enumerateChildNodes(withName: "background") { node, _ in
            let background = node as! SKSpriteNode
            if background.position.x + background.size.width < self.cameraRect.origin.x{
                background.position = CGPoint(x: background.position.x + background.size.width*2, y: background.position.y)
            }
        }        
    }
    
// MARK: Scrolling background
    
    func backgroundNode() -> SKSpriteNode {
        let backgroundNode = SKSpriteNode()
        backgroundNode.anchorPoint = CGPoint.zero
        backgroundNode.name =  "background"
        
        let background1 = SKSpriteNode(imageNamed: "background1")
        background1.anchorPoint = CGPoint.zero
        background1.position = CGPoint(x:0, y:0)
        backgroundNode.addChild(background1)
        
        let background2 = SKSpriteNode(imageNamed: "background2")
        background2.anchorPoint = CGPoint.zero
        background2.position = CGPoint(x:background1.size.width, y:0)
        backgroundNode.addChild(background2)
        
        backgroundNode.size = CGSize(width: background1.size.width + background2.size.width, height: background1.size.height)
        
        return backgroundNode
    }
    
    
}
