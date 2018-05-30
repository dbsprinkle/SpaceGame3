//
//  RestartScene.swift
//  spaceGame2
//
//  Created by Destinee Sprinkle on 5/21/18.
//  Copyright © 2018 Destinee Sprinkle. All rights reserved.
//

import SpriteKit

class RestartScene: SKScene {
    
    var starField:SKEmitterNode!
    var restartButtonNode:SKSpriteNode!
    var backToMenuButtonNode:SKSpriteNode!
    var destroyedLabel:SKLabelNode!
    
    var customBackgroundColor = UIColor(red: 0.000, green: 0.001, blue: 0.153, alpha: 1)
    
    override func didMove(to view: SKView) {
        //sets up the user defaults for the next scene
        UserDefaults().set(false, forKey: "VISITED")
        UserDefaults().set(3, forKey: "LIVES")
        
        starField = SKEmitterNode(fileNamed: "StarField")
        starField.position = CGPoint(x: 400, y: 1400)
        starField.advanceSimulationTime(10)
        self.addChild(starField)
        starField.zPosition = -1
        
        self.backgroundColor = customBackgroundColor
        
        restartButtonNode = SKSpriteNode(imageNamed: "restartTexture")
        restartButtonNode.position = CGPoint(x: 375, y: 550)
        self.addChild(restartButtonNode)
        
        backToMenuButtonNode = SKSpriteNode(imageNamed: "backToMenuTexture")
        backToMenuButtonNode.position = CGPoint(x: 375, y: 350)
        self.addChild(backToMenuButtonNode)
        
        //create and add label
        destroyedLabel = SKLabelNode(text: "Your rocket was destroyed")
        destroyedLabel.position = CGPoint(x: 375, y: 1000)
        destroyedLabel.fontName = "PingFangSC-Light"
        destroyedLabel.fontSize = 58
        destroyedLabel.fontColor = UIColor.white
        self.addChild(destroyedLabel)
        self.run(SKAction.playSoundFileNamed("You-lose-sound-effect.mp3", waitForCompletion: false))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        if let location = touch?.location(in: self){
            let nodesArray = self.nodes(at: location)
            if nodesArray.first == restartButtonNode{
                let transition = SKTransition.fade(withDuration: 0.5)
                if let scene = SKScene(fileNamed: "GameScene") {
                    // Set the scale mode to scale to fit the window
                    scene.scaleMode = .aspectFill
                    self.view?.presentScene(scene, transition: transition)
                }
            }
            if nodesArray.first == backToMenuButtonNode{
                let transition = SKTransition.fade(withDuration: 0.5)
                if let scene = MenuScene(fileNamed: "MenuScene"){
                    scene.scaleMode = .aspectFill
                    self.view?.presentScene(scene, transition: transition)
                }
            }
        }
    }
}
