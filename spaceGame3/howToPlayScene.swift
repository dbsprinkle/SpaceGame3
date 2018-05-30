//
//  howToPlayScene.swift
//  spaceGame3
//
//  Created by Destinee Sprinkle on 5/29/18.
//  Copyright © 2018 Destinee Sprinkle. All rights reserved.
//

import SpriteKit

class howToPlayScene: SKScene {

    var customBackgroundColor = UIColor(red: 0.000, green: 0.001, blue: 0.153, alpha: 1)
    
    var backStory:SKSpriteNode!
    var step1:SKSpriteNode!
    var step2:SKSpriteNode!
    var backButton:SKSpriteNode!
    var starField:SKEmitterNode!
    
    
    override func didMove(to view: SKView) {
        self.childNode(withName: "backStory")
        self.childNode(withName: "HTP")
        self.childNode(withName: "step1")
        self.childNode(withName: "step2")
        
        //create the star field as a SKEmitterNode  and give it a position
        starField = SKEmitterNode(fileNamed: "StarField")
        starField.position = CGPoint(x: 0, y: 1400)
        //advance simulation so the whole screen is covered with stars when the game starts
        starField.advanceSimulationTime(10)
        //add starfield to the screen
        self.addChild(starField)
        //place it behind everything we will add
        starField.zPosition = -1
        
    }
    
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
  
        if let location = touch?.location(in: self){
            let nodesArray = self.nodes(at: location)
            if nodesArray.first?.name == "backButton" {
        
                    let transition = SKTransition.flipVertical(withDuration: 0.5)
                    if let scene = MenuScene(fileNamed: "MenuScene"){
                        scene.scaleMode = .aspectFill
                        self.view?.presentScene(scene, transition: transition)
                    }
                }
            }
        }
    

    
    
}
