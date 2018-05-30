//
//  MenuScene.swift
//  SpaceGame
//
//  Created by Kathryn McGowin on 5/21/18.
//  Copyright © 2018 Furman University. All rights reserved.
//

import SpriteKit

class MenuScene: SKScene {

//    var starfield:SKEmitterNode!
    var newGameButtonNode:SKSpriteNode!
    var difficultyButtonNode:SKSpriteNode!
    var difficultyLabelNode:SKLabelNode!
    var rocket1Node:SKSpriteNode!
    var starField:SKEmitterNode!
    var blastoff:SKEmitterNode!
    var faqButtonNode:SKSpriteNode!
    var popUp:SKSpriteNode!
    var negRocket = false
    
    
    override func didMove(to view: SKView) {
        popUp = self.childNode(withName: "popUp") as! SKSpriteNode
        popUp.isHidden = true
        rocket1Node = self.childNode(withName: "rocket1") as! SKSpriteNode
        
        starField = SKEmitterNode(fileNamed: "StarField")
        starField.position = CGPoint(x: 0, y: 1472)
        //advance simulation so the whole screen is covered with stars when the game starts
        starField.advanceSimulationTime(10)
        starField.isPaused = true
        //add starfield to the screen
        self.addChild(starField)
        //place it behind everything we will add
        starField.zPosition = -1
        newGameButtonNode = self.childNode(withName: "newGameButton") as! SKSpriteNode
        
        difficultyLabelNode = self.childNode(withName: "difficultyLabel") as! SKLabelNode
        
        rocket1Node = self.childNode(withName: "rocket1") as! SKSpriteNode
       
        
        
        let userDefaults = UserDefaults.standard
        if userDefaults.bool(forKey: "hard") {
            difficultyLabelNode.text = "Hard"
        } else {
            difficultyLabelNode.text = "Easy"
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
       //print("touches began")
        if let location = touch?.location(in: self){
            let nodesArray = self.nodes(at: location)
            if nodesArray.first == newGameButtonNode {
                self.rocketBlastoff()
                self.run(SKAction.wait(forDuration: 1)){
                    let transition = SKTransition.flipVertical(withDuration: 0.5)
                    if let gameScene = SKScene(fileNamed: "GameScene"){
                        gameScene.scaleMode = .aspectFill
                        self.view?.presentScene(gameScene, transition: transition)
                    }
                }
                
                //rocketBlastoff()
                //print("New Game")
            } else if nodesArray.first?.name == "difficultyButton" {
                changeDifficulty()
            }else if nodesArray.first == rocket1Node {
                changeRocket()
            }else if nodesArray.first?.name == "howToPlayButton"{
                self.run(SKAction.wait(forDuration: 1)){
                    let transition = SKTransition.flipVertical(withDuration: 0.5)
                    if let scene = SKScene(fileNamed: "howToPlayScene"){
                        scene.scaleMode = .aspectFill
                        self.view?.presentScene(scene, transition: transition)
                    }
                    }
            }else if nodesArray.first?.name == "OkayButton"{
                popUp.isHidden = true
            }
        }
}
    
    func changeRocket(){
        //if the player doesn't have enough coins
        let coinCheck = GameScene().checkCoins()
        //tell them
        popUp.isHidden = false
        if coinCheck{
        //switch which rocket is shown on screen and used in the gamee
        let negRocketNode = SKSpriteNode(imageNamed: "smallRocketNeg-cutout")
        let ogRocketNode = SKSpriteNode(imageNamed:"rocket-cutout-fire")
        if negRocket == false{
            rocket1Node.removeFromParent()
            negRocketNode.position = rocket1Node.position
            self.addChild(negRocketNode)
            rocket1Node = negRocketNode
            checkRocket()
        }else if negRocket == true{
            rocket1Node.removeFromParent()
            ogRocketNode.position = rocket1Node.position
            self.addChild(ogRocketNode)
            rocket1Node = ogRocketNode
            checkRocket()
        }
    }
}
    
    func checkRocket() -> Bool{
        if negRocket == false{
            negRocket = true
        }else if negRocket == true{
            negRocket = false
        }
        return negRocket
    }
    
    func changeDifficulty() {
        let userDefaults = UserDefaults.standard
        if difficultyLabelNode.text == "Easy"{
            difficultyLabelNode.text = "Hard"
            userDefaults.set(true, forKey: "hard")
            userDefaults.set(false, forKey: "easy")
        } else {
            difficultyLabelNode.text = "Easy"
            userDefaults.set(true, forKey: "easy")
            userDefaults.set(false, forKey: "hard")
        }
        
        userDefaults.synchronize()
    }
    
    func rocketBlastoff() {
        rocket1Node.physicsBody = SKPhysicsBody(rectangleOf: rocket1Node.size)
        rocket1Node.physicsBody?.isDynamic = true
        blastoff = SKEmitterNode(fileNamed: "blastoff")
        blastoff.position.y = rocket1Node.position.y - 10
        self.addChild(blastoff)
        blastoff.physicsBody = SKPhysicsBody(rectangleOf: rocket1Node.size)
        blastoff.physicsBody?.isDynamic = true
        var actionArray = [SKAction]()
        actionArray.append(SKAction.move(to: CGPoint(x: rocket1Node.position.x, y: self.frame.size.height + 10), duration: 1))
        actionArray.append(SKAction.removeFromParent())
        rocket1Node.run(SKAction.sequence(actionArray))
        blastoff.run(SKAction.sequence(actionArray))
        starField.isPaused = false
    }
}
