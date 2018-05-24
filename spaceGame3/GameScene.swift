//
//  GameScene.swift
//  spaceGame
//
//  Created by Destinee Sprinkle on 5/17/18.
//  Copyright © 2018 Destinee Sprinkle. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreMotion

class GameScene: SKScene, SKPhysicsContactDelegate{
    
    let rocket = SKSpriteNode(imageNamed: "smallRocket.png")
    var starField:SKEmitterNode!
    var scoreLabel:SKLabelNode!
    //creates and updates score label
    var score:Int = 0 {
        didSet{
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var obstacleTimer:Timer!
    
    var possibleObstacles = ["smallAsteroid", "alien2-cutout"]
    
    var rocketCategory:UInt32 = 0x1 << 2
    var obstacleCategory:UInt32 = 0x1 << 0
    var laserCategory:UInt32 = 0x1 << 1
    
    let motionManager = CMMotionManager()
    var xAcceleration:CGFloat = 0
    
    var customBackgroundColor = UIColor(red: 0.000, green: 0.001, blue: 0.153, alpha: 1)
    
    var livesArray:[SKSpriteNode]!
    
    
    
    
    override func didMove(to view: SKView) {
         addLives()
        //create the star field as a SKEmitterNode  and give it a position
        starField = SKEmitterNode(fileNamed: "StarField")
        starField.position = CGPoint(x: 0, y: 1400)
        //advance simulation so the whole screen is covered with stars when the game starts
        starField.advanceSimulationTime(10)
        //add starfield to the screen
        self.addChild(starField)
        //place it behind everything we will add
        starField.zPosition = -1
        
        self.backgroundColor = customBackgroundColor
        
        //add rocket to the screen
        rocket.position = CGPoint(x: 0 , y: -500)
        self.addChild(rocket)
        
        //add a physics body to the rocket
        rocket.physicsBody = SKPhysicsBody(rectangleOf: rocket.size)
        rocket.physicsBody?.isDynamic = true
        
        //create bit masks for the rocket
        rocket.physicsBody?.categoryBitMask = rocketCategory
        rocket.physicsBody?.contactTestBitMask = obstacleCategory
        rocket.physicsBody?.collisionBitMask = 0
        rocket.physicsBody?.usesPreciseCollisionDetection = true
        
        //no gravity
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
        
        //create and add label
        scoreLabel = SKLabelNode(text: "Score: 0")
        scoreLabel.position = CGPoint(x: -300, y: 600)
        scoreLabel.fontName = "PingFangSC-Light"
        scoreLabel.fontSize = 32
        scoreLabel.fontColor = UIColor.white
        score = 0
        self.addChild(scoreLabel)
        
        var timeInterval = 0.75
        if UserDefaults.standard.bool(forKey: "hard") {
            timeInterval = 0.3
        }
        
        //add an asteroid after time interval(change this to make the game more difficult)
        obstacleTimer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(addObstacle), userInfo: nil, repeats: true)
        //gets the acceleration data(how fast you are moving the phone)
        motionManager.accelerometerUpdateInterval = 0.2
        motionManager.startAccelerometerUpdates(to: OperationQueue.current!) {(data:CMAccelerometerData?, error:Error?) in
            if let accelerometerData = data{
                let accelerometer = accelerometerData.acceleration
                self.xAcceleration = CGFloat(accelerometer.x * 0.75) + self.xAcceleration * 0.25
            }
        }
    }
    
    func addLives() {
        livesArray = [SKSpriteNode]()
        
        for live in 1...3 {
            let liveNode = SKSpriteNode(imageNamed: "rocket-cutout-fire-1")
            liveNode.position = CGPoint(x: self.frame.size.width - CGFloat(4-live) * liveNode.size.width, y: self.frame.size.height - 60)
            self.addChild(liveNode)
        }
    }
    
    
    //add an asteroid to the screen at a random position and removes it when it goes off the bottom
    @objc func addObstacle(){
        possibleObstacles = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: possibleObstacles) as! [String]
        let obstacle = SKSpriteNode(imageNamed: possibleObstacles[0])
        
        let randomObstaclePostion = GKRandomDistribution(lowestValue: -400, highestValue: 400)
        let position = CGFloat(randomObstaclePostion.nextInt())
        obstacle.position = CGPoint(x: position, y: self.frame.size.height + obstacle.size.height)
        
        obstacle.physicsBody = SKPhysicsBody(circleOfRadius: obstacle.size.width / 2)
        obstacle.physicsBody?.isDynamic = true
        obstacle.physicsBody?.categoryBitMask = obstacleCategory
        obstacle.physicsBody?.contactTestBitMask = rocketCategory
        obstacle.physicsBody?.collisionBitMask = 0
        
        self.addChild(obstacle)
        
        var actionArray = [SKAction]()
        actionArray.append(SKAction.move(to:CGPoint(x: position, y:-750), duration: 6))
        actionArray.append(SKAction.removeFromParent())
        
        obstacle.run(SKAction.sequence(actionArray))
        
        
    }
    
  
    //use the bit mask of the rocket and the asteroid to see if they have collided
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody:SKPhysicsBody
        var secondBody:SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask{
            firstBody = contact.bodyA
            secondBody = contact.bodyB
         
        }else{
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        if (firstBody.categoryBitMask & obstacleCategory) != 0 && (secondBody.categoryBitMask & rocketCategory) != 0{
            rocketCrashedIntoObstacle(obstacleNode: firstBody.node as! SKSpriteNode, rocketNode: secondBody.node as! SKSpriteNode)
        }else if (firstBody.categoryBitMask & obstacleCategory) != 0 && (secondBody.categoryBitMask & laserCategory) != 0{
            laserHitObstacle(obstacleNode: firstBody.node as! SKSpriteNode, laserNode: secondBody.node as! SKSpriteNode)
        }
    }
    
    //removes the rocket and asteroid if the collided and shows an explosion for 2 seconds
    func rocketCrashedIntoObstacle(obstacleNode:SKSpriteNode, rocketNode:SKSpriteNode){
        let explosion = SKEmitterNode(fileNamed: "explosion")!
        explosion.position = rocketNode.position
        self.addChild(explosion)
        
        self.run(SKAction.playSoundFileNamed("Blast-Sound.mp3", waitForCompletion: false))
        
        obstacleNode.removeFromParent()
        rocketNode.removeFromParent()
        
        self.run(SKAction.wait(forDuration: 1)){
            explosion.removeFromParent()
        
            if self.livesArray.count > 0 {
                let liveNode = self.livesArray.first
                liveNode!.removeFromParent()
                self.livesArray.removeFirst()
            }
            if self.livesArray.count == 0 {
                //transition to gameover
                let restartTransition = SKTransition.fade(withDuration: 0.5)
                let restartScene = RestartScene(size: self.size)
                self.view?.presentScene(restartScene, transition: restartTransition)
            }
            
        
        
    }
    }
    
    
   
    func fireLaser(){
        let laser = SKSpriteNode(imageNamed: "laser")
        laser.position = rocket.position
        
        laser.physicsBody = SKPhysicsBody(rectangleOf: laser.size )
        laser.physicsBody?.isDynamic = true
        laser.physicsBody?.categoryBitMask = laserCategory
        laser.physicsBody?.contactTestBitMask = obstacleCategory

        laser.physicsBody?.collisionBitMask = 0
        laser.physicsBody?.usesPreciseCollisionDetection = true
        
        self.addChild(laser)
        
        var actionArray = [SKAction]()
        actionArray.append(SKAction.move(to: CGPoint(x: rocket.position.x, y: self.frame.size.height + 10), duration: 0.3))
        actionArray.append(SKAction.removeFromParent())
        
        laser.run(SKAction.sequence(actionArray))
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        fireLaser()
    }
 
    
    func laserHitObstacle(obstacleNode:SKSpriteNode, laserNode:SKSpriteNode){
        let explosion = SKEmitterNode(fileNamed: "explosion")!
        explosion.position = obstacleNode.position
        self.addChild(explosion)
        
        self.run(SKAction.playSoundFileNamed("Blast_Sound.mp3", waitForCompletion: false))
        
        obstacleNode.removeFromParent()
        laserNode.removeFromParent()
        
        self.run(SKAction.wait(forDuration: 1)){
            explosion.removeFromParent()
    }
        score += 1
    }
    
    
    //moves the rocket using the accelerator data
    override func didSimulatePhysics() {
        rocket.position.x += xAcceleration * 50
        if rocket.position.x < -500{
            rocket.position = CGPoint(x: self.size.width + 20, y: rocket.position.y)
        }else if rocket.position.x > self.size.width + 20{
            rocket.position = CGPoint(x: -20, y: rocket.position.y)
        }
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        //Called before each frame is rendered
    }
}

