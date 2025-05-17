import SpriteKit
import AVFoundation

class GameScene: SKScene {
    var selectedCategory: GameCategory = .actions
    var correctNode: SKSpriteNode?
    var questionLabel: SKLabelNode!
    var feedbackLabel: SKLabelNode!
    let synthesizer = AVSpeechSynthesizer()

    override func didMove(to view: SKView) {
        backgroundColor = .white
        setupLabels()
        addBackButton()
        showCards()
    }

    func setupLabels() {
        // Верхняя надпись (вопрос)
        questionLabel = SKLabelNode(text: "")
        questionLabel.fontName = "AvenirNext-Bold"
        questionLabel.fontSize = 36
        questionLabel.fontColor = .black
        questionLabel.position = CGPoint(x: frame.midX, y: 750)
        questionLabel.zPosition = 1
        addChild(questionLabel)

        // Нижняя надпись (результат)
        feedbackLabel = SKLabelNode(text: "")
        feedbackLabel.fontName = "AvenirNext-Regular"
        feedbackLabel.fontSize = 32
        feedbackLabel.fontColor = .systemGreen
        feedbackLabel.position = CGPoint(x: frame.midX, y: 50)
        feedbackLabel.zPosition = 1
        addChild(feedbackLabel)
    }

    func showCards() {
        // Удаляем только карточки (не трогаем лейблы)
        children.filter { $0 is SKSpriteNode }.forEach { $0.removeFromParent() }

        let allCards: [(String, String)] = {
            switch selectedCategory {
            case .actions:
                return [("wash_hands", "Мыть руки"), ("eat", "Есть"), ("sleep", "Спать"), ("play", "Играть")]
            case .colors:
                return [("red", "Красный"), ("blue", "Синий"), ("yellow", "Жёлтый"), ("green", "Зелёный")]
            case .toys:
                return [("car", "Машинка"), ("ball", "Мяч"), ("bear", "Мишка"), ("blocks", "Кубики")]
            case .animals:
                return [("dog", "Собака"), ("cat", "Кошка"), ("cow", "Корова"), ("rabbit", "Кролик")]
            }
        }()

        // Случайная правильная карточка
        guard let correctCard = allCards.randomElement() else { return }

        // Выбираем 3 других, перемешиваем
        var cards = allCards.filter { $0.0 != correctCard.0 }.shuffled()
        cards = Array(cards.prefix(3))
        cards.append(correctCard)
        cards.shuffle()

        let cardSize = CGSize(width: 140, height: 140)
        let spacing: CGFloat = 20
        let totalCardHeight = CGFloat(cards.count) * cardSize.height
        let totalSpacingHeight = CGFloat(cards.count - 1) * spacing
        let totalHeight = totalCardHeight + totalSpacingHeight

        // Центрирование по вертикали (ниже центра — чтобы не мешать надписи)
        let startY = (frame.height - totalHeight) / 2
        let x = frame.midX

        for (index, (imageName, label)) in cards.enumerated() {
            let card = SKSpriteNode(imageNamed: imageName)
            card.name = (imageName == correctCard.0) ? "correct" : "wrong"
            card.size = cardSize

            let y = startY + CGFloat(index) * (cardSize.height + spacing) + cardSize.height / 2
            card.position = CGPoint(x: x, y: y)

            addChild(card)
        }

        // Обновляем задание и озвучиваем
        questionLabel.text = "Покажи: \(correctCard.1)"
        speak("Покажи: \(correctCard.1)")
        feedbackLabel.text = ""
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: self) else { return }

        let tappedNodes = nodes(at: location)
        for tappedNode in tappedNodes {
            if let nodeName = tappedNode.name, nodeName == "backButton" {
                if let view = self.view {
                    let menuScene = MenuScene(size: self.size)
                    menuScene.scaleMode = .aspectFill
                    view.presentScene(menuScene, transition: .fade(withDuration: 0.4))
                }
                return
            }

            if tappedNode.name == "correct" {
                feedbackLabel.fontColor = .systemGreen
                feedbackLabel.text = "Молодец!"
                speak("Молодец!")
                run(SKAction.wait(forDuration: 2.0)) {
                    self.showCards()
                }
            } else if tappedNode.name == "wrong" {
                feedbackLabel.fontColor = .red
                feedbackLabel.text = "Попробуй ещё"
                speak("Попробуй ещё")
            }
        }
    }

    func speak(_ phrase: String) {
        let utterance = AVSpeechUtterance(string: phrase)
        utterance.voice = AVSpeechSynthesisVoice(language: "ru-RU")
        synthesizer.speak(utterance)
    }
    
    func addBackButton() {
        let button = SKShapeNode(rectOf: CGSize(width: 80, height: 35), cornerRadius: 12)
        button.fillColor = .systemGray3
        button.name = "backButton"
        button.position = CGPoint(x: frame.minX + 75, y: frame.maxY - 40)
        button.zPosition = 2
        addChild(button)

        let label = SKLabelNode(text: "Назад")
        label.fontName = "AvenirNext-Bold"
        label.fontSize = 20
        label.fontColor = .black
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        label.position = .zero
        label.name = "backButton"
        button.addChild(label)
    }
}
