//
//  coinScene.swift
//  spaceGame3
//
//  Created by Destinee Sprinkle on 5/25/18.
//  Copyright © 2018 Destinee Sprinkle. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreMotion

class coinScene: SKScene, SKPhysicsContactDelegate {

    //nodes for the coin screen
    var rocket:SKSpriteNode!
    var starField:SKEmitterNode!
    var coinLabel:SKLabelNode!
    
    //creates and updates score label
    var coins:Int = 0 {
        didSet{
            coinLabel.text = "Coins: \(coins)"
        }
    }
    //bit mask categories to be used in collison testing
    var rocketCategory:UInt32 = 0x1 << 1
    var coinCategory:UInt32 = 0x1 << 0
    
    var coinTimer:Timer!
    var sceneTimer:Timer!
    
    let motionManager = CMMotionManager()
    var xAcceleration:CGFloat = 0
   // var yAccerleration:CGFloat = 0
    
    var customBackgroundColor = UIColor(red: 0.000, green: 0.001, blue: 0.153, alpha: 1)
    
    var visited = UserDefaults().bool(forKey: "VISITED")
    
    override func didMove(to view: SKView) {
        UserDefaults().set(true, forKey: "VISITED")
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
        rocket.physicsBody?.contactTestBitMask = coinCategory
        rocket.physicsBody?.collisionBitMask = 0
        rocket.physicsBody?.usesPreciseCollisionDetection = true
        
        //screen constraints
        let range = SKRange(lowerLimit: -330, upperLimit: 330)
        let range2 = SKRange(lowerLimit: -650, upperLimit: 650)
        
        let lockToCenter = SKConstraint.positionX(range, y: range2)
        
        rocket.constraints = [ lockToCenter ]
        
        //no gravity
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
        
        //create and add label
        coinLabel = SKLabelNode(text: "Score: \(coins)")
        coinLabel.position = CGPoint(x: -300, y: 600)
        coinLabel.fontName = "PingFangSC-Light"
        coinLabel.fontSize = 32
        coinLabel.fontColor = UIColor.white
        self.addChild(coinLabel)
        
        
        //times when the coins will appear on screen and how long the player will be in the coin level
        coinTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(addCoin), userInfo: nil, repeats: true)
        sceneTimer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(transitionsToGame), userInfo: nil, repeats: false)
            
        //gets the acceleration data(how fast you are moving the phone)
        motionManager.accelerometerUpdateInterval = 0.2
        motionManager.startAccelerometerUpdates(to: OperationQueue.current!) {(data:CMAccelerometerData?, error:Error?) in
            if let accelerometerData = data{
                let accelerometer = accelerometerData.acceleration
                self.xAcceleration = CGFloat(accelerometer.x * 0.75) + self.xAcceleration * 0.25
               // self.yAccerleration = CGFloat(accelerometer.y * 0.75) + self.xAcceleration * 0.25
            }
        }
        
    }
    
    @objc func addCoin(){
        //adds a coin at a random location on the screen
        let coin = SKSpriteNode(imageNamed: "goldCoin")
        let randomCoinPostion = GKRandomDistribution(lowestValue: -400, highestValue: 400)
        let position = CGFloat(randomCoinPostion.nextInt())
        coin.position = CGPoint(x: position, y: self.frame.size.height + coin.size.height)
        
        //physics used for collison
        coin.physicsBody = SKPhysicsBody(circleOfRadius: coin.size.width / 2)
        coin.physicsBody?.isDynamic = true
        coin.physicsBody?.categoryBitMask = coinCategory
        coin.physicsBody?.contactTestBitMask = rocketCategory
        coin.physicsBody?.collisionBitMask = 0
        
        self.addChild(coin)
        
        //move the coin down the screen and off the view
        var actionArray = [SKAction]()
        actionArray.append(SKAction.move(to:CGPoint(x: position, y:-750), duration: 6))
        actionArray.append(SKAction.removeFromParent())
        
        coin.run(SKAction.sequence(actionArray))
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody:SKPhysicsBody
        var secondBody:SKPhysicsBody
        
        //check to see if the rocket hit the coin
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask{
            firstBody = contact.bodyA
            secondBody = contact.bodyB
            
        }else{
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        if (firstBody.categoryBitMask & coinCategory) != 0 && (secondBody.categoryBitMask & rocketCategory) != 0{
            gotCoin(coinNode: firstBody.node as! SKSpriteNode, rocketNode: secondBody.node as! SKSpriteNode)
        }
    }
    
    //remove coin from view when rocket hits it
    func gotCoin(coinNode:SKSpriteNode, rocketNode:SKSpriteNode){
        coinNode.removeFromParent()
        coins += 1
        UserDefaults().set(coins, forKey: "COINS")
        coinLabel.text = "Coins: \(coins)"
    }
    
    //transition back to the main game
    @objc func transitionsToGame() {
        let transition = SKTransition.fade(withDuration: 0.5)
        if let scene = SKScene(fileNamed: "GameScene") {
            // Set the scale mode to scale to fit the window
            scene.scaleMode = .aspectFill
            self.view?.presentScene(scene, transition: transition)
        }
    }
    //moves rocket left and right and up and down
    // up and down is really hard, don't reccommend
    override func didSimulatePhysics() {
        rocket.position.x += xAcceleration * 50
        // rocket.position.y += yAccerleration * 50
        if rocket.position.x < -500 {
            rocket.position = CGPoint(x: self.size.width + 20, y: rocket.position.y)
        }else if rocket.position.x > self.size.width + 20{
            rocket.position = CGPoint(x: -20, y: rocket.position.y)
        }
        /*if rocket.position.y < -500{
         rocket.position = CGPoint(x: rocket.position.x, y: self.size.height + 20)
         }else if rocket.position.y > self.size.height + 20{
         rocket.position = CGPoint(x: rocket.position.x, y: -20)
         }*/
    }
    
    }

    



