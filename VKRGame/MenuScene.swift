import SpriteKit

class MenuScene: SKScene {
    override func didMove(to view: SKView) {
        backgroundColor = .white
        createMenu()
    }

    func createMenu() {
        let categories: [(GameCategory, UIColor)] = [
            (.actions, .systemBlue),
            (.colors, .systemGreen),
            (.toys, .systemOrange),
            (.animals, .systemPurple)
        ]

        let spacing: CGFloat = 30
        let buttonSize = CGSize(width: 300, height: 80)
        let totalHeight = CGFloat(categories.count) * buttonSize.height + CGFloat(categories.count - 1) * spacing
        let startY = (frame.height - totalHeight) / 2

        for (index, (category, color)) in categories.enumerated() {
            let button = SKShapeNode(rectOf: buttonSize, cornerRadius: 16)
            button.fillColor = color
            button.name = category.rawValue
            button.position = CGPoint(x: frame.midX, y: startY + CGFloat(index) * (buttonSize.height + spacing) + buttonSize.height / 2)
            addChild(button)

            let label = SKLabelNode(text: category.rawValue)
            label.fontName = "AvenirNext-Bold"
            label.fontSize = 24
            label.fontColor = .white
            label.verticalAlignmentMode = .center
            label.position = .zero
            button.addChild(label)
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: self) else { return }
        
        let tappedNodes = nodes(at: location)
        for node in tappedNodes {
            if let name = node.name, let selectedCategory = GameCategory(rawValue: name) {
                if let view = self.view {
                    let scene = GameScene(size: self.size)
                    scene.selectedCategory = selectedCategory
                    scene.scaleMode = .aspectFill
                    view.presentScene(scene, transition: .fade(withDuration: 0.5))
                }
            }
        }        
    }
}
