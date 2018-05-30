//
//  MenuScene.swift
//  SpaceGame
//
//  Created by Kathryn McGowin on 5/21/18.
//  Copyright © 2018 Furman University. All rights reserved.
//

import SpriteKit

class MenuScene: SKScene {
    //creates nodes for scene
    var newGameButtonNode:SKSpriteNode!
    var difficultyButtonNode:SKSpriteNode!
    var difficultyLabelNode:SKLabelNode!
    var rocket1Node:SKSpriteNode!
    var starField:SKEmitterNode!
    var blastoff:SKEmitterNode!
    var faqButtonNode:SKSpriteNode!
    var popUp:SKSpriteNode!
    //variable for rocket change
    var negRocket = false
    
    
    override func didMove(to view: SKView) {
        //variable to ensure that the score starts over
        UserDefaults().set(false, forKey: "VISITED")
        UserDefaults().set(3, forKey: "LIVES")
        
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
        
        popUp = self.childNode(withName: "popUp") as! SKSpriteNode
       
        
        //changes difficulty levels
        let userDefaults = UserDefaults.standard
        if userDefaults.bool(forKey: "hard") {
            difficultyLabelNode.text = "Hard"
        } else {
            difficultyLabelNode.text = "Easy"
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        if let location = touch?.location(in: self){
            let nodesArray = self.nodes(at: location)
            //start new game
            if nodesArray.first == newGameButtonNode {
                self.rocketBlastoff()
                self.run(SKAction.wait(forDuration: 1)){
                    //transitions to game scene
                    let transition = SKTransition.flipVertical(withDuration: 0.5)
                    if let gameScene = SKScene(fileNamed: "GameScene"){
                        gameScene.scaleMode = .aspectFill
                        self.view?.presentScene(gameScene, transition: transition)
                    }
                }
                
            } else if nodesArray.first?.name == "difficultyButton" {
                changeDifficulty()
            }else if nodesArray.first == rocket1Node {
                changeRocket()
            //demonstrates how to play the game
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
        if coinCheck{
        //switch which rocket is shown on screen and used in the game
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
        else{
            //tell them
            popUp.isHidden = false
        }
}
    
    func checkRocket() -> Bool{
        if negRocket == false{
            negRocket = true
        }else if negRocket == true{
            negRocket = false
        }
        print(negRocket)
        return negRocket
    }
    
    //function to actually change the difficulty
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
    
    //creates the impression of a rocket blastoff
    func rocketBlastoff() {
        //prepares the rocket to move
        rocket1Node.physicsBody = SKPhysicsBody(rectangleOf: rocket1Node.size)
        rocket1Node.physicsBody?.isDynamic = true
        //orients rocket towards the top
        let lookAtConstraint = SKConstraint.orient(to: CGPoint(x: 0, y: 400),
                                                   offset: SKRange(constantValue: -CGFloat.pi / 2))
        rocket1Node.constraints = [ lookAtConstraint ]
        //prepares the blastoff to move
        blastoff = SKEmitterNode(fileNamed: "blastoff")
        blastoff.position.y = rocket1Node.position.y - 20
        self.addChild(blastoff)
        blastoff.physicsBody = SKPhysicsBody(rectangleOf: rocket1Node.size)
        blastoff.physicsBody?.isDynamic = true
        //moves both
        var actionArray = [SKAction]()
        actionArray.append(SKAction.move(to: CGPoint(x: rocket1Node.position.x, y: self.frame.size.height + 10), duration: 1))
        actionArray.append(SKAction.removeFromParent())
        rocket1Node.run(SKAction.sequence(actionArray))
        blastoff.run(SKAction.sequence(actionArray))
        starField.isPaused = false
    }
}
