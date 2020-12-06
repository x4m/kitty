//
//  GameScene.swift
//  kitty
//
//  Created by Andrey M. Borodin on 05.12.2020.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    private var spinnyNode : SKShapeNode?
    private var podNode : SKShapeNode?
    private var ballNode : SKShapeNode?
    private var dx:CGFloat = 10
    private var dy:CGFloat = 10
    private var bricks:[[SKShapeNode?]]?
    
    fileprivate func ResetBricks(_ brickWidth: CGFloat, _ brickHieght: CGFloat, _ w: CGFloat) {
        
        if bricks != nil {
            for i in 0...4 {
                for o in 0...8 {
                    let b = self.bricks![i][o]
                    if b == nil {
                        continue
                    }
                    self.removeChildren(in: [b!])
                }
            }
        }
        
        bricks = Array(repeating: Array(repeating: nil, count: 9), count: 5)
        
        for i in 0...4 {
            for o in 0...8 {
                bricks![i][o] = SKShapeNode.init(rectOf: CGSize.init(width: brickWidth, height: brickHieght), cornerRadius: w * 0.03)
                bricks![i][o]!.strokeColor = SKColor.green
                bricks![i][o]!.glowWidth = 3
                var x = -self.size.width / 2.5
                var y = self.size.height / 2.5
                x = x + self.size.width * CGFloat.init(i) / 5.0
                y = y - self.size.height * CGFloat.init(o) / 25.0
                bricks![i][o]!.position = CGPoint.init(x: x, y: y )
                self.addChild(bricks![i][o]!)
            }
        }
    }
    
    override func didMove(to view: SKView) {
        
        // Get label node from scene and store it for use later
//        self.label = self.childNode(withName: "//helloLabel") as? SKLabelNode
//        if let label = self.label {
//            label.alpha = 0.0
//            label.run(SKAction.fadeIn(withDuration: 2.0))
//        }
        
        // Create shape node to use during mouse interaction
        let w = (self.size.width + self.size.height) * 0.10
        self.spinnyNode = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.1)
        
        if let spinnyNode = self.spinnyNode {
            spinnyNode.lineWidth = 2.5
            
            spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 1)))
            spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
                                              SKAction.fadeOut(withDuration: 0.5),
                                              SKAction.removeFromParent()]))
        }
        
        let ballSize: CGFloat = w/5
        ballNode = SKShapeNode.init(rectOf: CGSize.init(width: ballSize, height: w/5), cornerRadius: w * 0.1)
        ballNode?.strokeColor = SKColor.red
        //ballNode?.lineWidth = 10
        ballNode?.fillColor = SKColor.yellow
        self.addChild(ballNode!)
        
        podNode = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w/5), cornerRadius: w * 0.1)
        podNode?.fillColor = SKColor.white
        
        if let n = podNode as SKShapeNode? {
            n.lineWidth = 4
            n.position = CGPoint.init(x: 0, y: -self.size.height / 2.5)
            self.addChild(n)
        }
        
        let brickWidth: CGFloat = w/1.5
        let brickHieght: CGFloat = w/5
        
        ResetBricks(brickWidth, brickHieght, w)
        
        let wait = SKAction.wait(forDuration: 0.02)
        let update = SKAction.run(
        {
            let b = self.ballNode
            var p = b!.position
            p.x += self.dx
            p.y += self.dy
            
            if p.x >= self.size.width/2.1 {
                self.dx = -self.dx
            }
            
            if p.x <= -self.size.width/2.1 {
                self.dx = -self.dx
            }
            if p.y >= self.size.height/2.4 {
                self.dy = -self.dy
            }
            
            if p.y <= -self.size.height/2.4 {
                self.dy = -self.dy
            }
            
            b?.position = p
            
            if p.y <= -self.size.height / 2.4 {
                self.ResetBricks(brickWidth, brickHieght, w)
            }
            
            let dx = abs(self.podNode!.position.x - self.ballNode!.position.x)
            let dy = abs(self.podNode!.position.y - self.ballNode!.position.y)
            
            if dx < (ballSize + w) / 2 {
                if dy < (ballSize + w/5) / 2 {
                    self.dy = -self.dy
                    self.dx = -(self.podNode!.position.x - self.ballNode!.position.x) * 20 / w
                    return
                }
            }
            
            for i in 0...4 {
                for o in 0...8 {
                    let b = self.bricks![i][o]
                    if b == nil {
                        continue;
                    }
                    let dx = abs(b!.position.x - self.ballNode!.position.x)
                    let dy = abs(b!.position.y - self.ballNode!.position.y)
                    var collision = false
                    if dx < (ballSize + brickWidth) / 2 {
                        if dy < (ballSize + brickHieght) / 2 {
                            collision = true
                        }
                    }
                    
                    if collision {
                        self.bricks![i][o] = nil
                        self.removeChildren(in: [b!])
                        if dx < brickWidth / 2 {
                            self.dy = -self.dy
                        }
                        else if dy < brickHieght / 2 {
                            self.dx = -self.dx
                        }
                        else {
                            self.dy = -self.dy
                            self.dx = -self.dx
                        }
                        return
                    }
                }
            }
        }
        )
        let seq = SKAction.sequence([wait,update])
        let r = SKAction.repeatForever(seq)
        run(r)
    }
    
    
    func touchDown(atPoint pos : CGPoint) {
//        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
//            n.position = pos
//            n.strokeColor = SKColor.green
//            self.addChild(n)
//        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
//        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
//            n.position = CGPoint.init(x: pos.x, y: 0)
//            n.strokeColor = SKColor.blue
//            self.addChild(n)
//        }
        podNode?.position = CGPoint.init(x: pos.x, y: -self.size.height / 2.5)
    }
    
    func touchUp(atPoint pos : CGPoint) {
//        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
//            n.position = pos
//            n.strokeColor = SKColor.red
//            self.addChild(n)
//        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        if let label = self.label {
//            label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
//        }
        
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
