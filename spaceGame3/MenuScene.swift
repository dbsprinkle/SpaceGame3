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
    
    override func didMove(to view: SKView) {
        
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
//        difficultyButtonNode = self.childNode(withName: "difficultyButton") as! SKSpriteNode
        
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
        print("touches began")
        if let location = touch?.location(in: self){
            let nodesArray = self.nodes(at: location)
            if nodesArray.first == newGameButtonNode {
                let transition = SKTransition.flipVertical(withDuration: 0.5)
                let gameScene = GameScene(size: self.size)
                self.view?.presentScene(gameScene, transition: transition)
                //rocketBlastoff()
                print("New Game")
            } else if nodesArray.first?.name == "difficultyButton" {
                changeDifficulty()
            }
        }
    }
    
    func changeDifficulty() {
        let userDefaults = UserDefaults.standard
        if difficultyLabelNode.text == "Easy"{
            difficultyLabelNode.text = "Hard"
            userDefaults.set(true, forKey: "hard")
        } else {
            difficultyLabelNode.text = "Easy"
            userDefaults.set(true, forKey: "easy")
        }
        
        userDefaults.synchronize()
    }
    
    func rocketBlastoff() {
        let takeoff = SKEmitterNode(fileNamed: "blastoff")!
        takeoff.position = rocket1Node.position
        self.addChild(takeoff)
        rocket1Node.removeFromParent()
        //self.addChild(rocket2)
    }
}
