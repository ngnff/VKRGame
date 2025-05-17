import SpriteKit
import AVFoundation

class EmotionRecognitionScene: SKScene {
    // Все доступные эмоции (imageName, название)
    let emotions: [(String, String)] = [
        ("emotion_happy", "Радость"),
        ("emotion_sad", "Грусть"),
        ("emotion_angry", "Злость"),
        ("emotion_surprised", "Удивление"),
        ("emotion_scared", "Страх"),
        ("emotion_disgusted", "Отвращение")
    ]
    
    // Текущая эмоция, которую нужно найти
    var currentEmotion: (String, String)?
    
    // Текущие отображаемые эмоции
    var displayedEmotions: [(String, String)] = []
    
    // Узлы эмоций на экране
    var emotionNodes: [SKSpriteNode] = []
    
    // UI элементы
    var questionLabel: SKLabelNode!
    var feedbackLabel: SKLabelNode!
    var levelLabel: SKLabelNode!
    
    // Синтезатор речи
    let synthesizer = AVSpeechSynthesizer()
    
    // Уровень игры
    var level = 1
    
    // Счетчик правильных ответов на текущем уровне
    var correctAnswers = 0
    
    // Количество правильных ответов, необходимых для перехода на следующий уровень
    let correctAnswersToLevelUp = 5
    
    override func didMove(to view: SKView) {
        backgroundColor = .white
        setupUI()
        startNewRound()
    }
    
    func setupUI() {
        // Заголовок с инструкцией
        questionLabel = SKLabelNode(text: "")
        questionLabel.fontName = "AvenirNext-Bold"
        questionLabel.fontSize = 30
        questionLabel.fontColor = .black
        questionLabel.position = CGPoint(x: frame.midX, y: frame.height - 60)
        questionLabel.zPosition = 5
        addChild(questionLabel)
        
        // Индикатор уровня
        levelLabel = SKLabelNode(text: "Уровень \(level)")
        levelLabel.fontName = "AvenirNext-Bold"
        levelLabel.fontSize = 24
        levelLabel.fontColor = .darkGray
        levelLabel.position = CGPoint(x: frame.width - 90, y: frame.height - 40)
        levelLabel.zPosition = 5
        addChild(levelLabel)
        
        // Обратная связь
        feedbackLabel = SKLabelNode(text: "")
        feedbackLabel.fontName = "AvenirNext-Regular"
        feedbackLabel.fontSize = 28
        feedbackLabel.fontColor = .systemGreen
        feedbackLabel.position = CGPoint(x: frame.midX, y: 50)
        feedbackLabel.zPosition = 5
        addChild(feedbackLabel)
        
        // Кнопка "Назад"
        addBackButton()
    }
    
    func startNewRound() {
        // Очищаем предыдущие эмоции
        for node in emotionNodes {
            node.removeFromParent()
        }
        emotionNodes.removeAll()
        displayedEmotions.removeAll()
        
        // Определяем количество эмоций для отображения в зависимости от уровня
        let emotionsToShow = min(2 + level, 6)
        
        // Перемешиваем эмоции и выбираем нужное количество
        let shuffledEmotions = emotions.shuffled()
        displayedEmotions = Array(shuffledEmotions.prefix(emotionsToShow))
        
        // Выбираем случайную эмоцию, которую нужно найти
        currentEmotion = displayedEmotions.randomElement()
        
        // Обновляем вопрос
        if let currentEmotion = currentEmotion {
            questionLabel.text = "Покажи: \(currentEmotion.1)"
            speak("Покажи: \(currentEmotion.1)")
        }
        
        // Размещаем эмоции на экране
        displayEmotions()
        
        // Обновляем отображение уровня
        levelLabel.text = "Уровень \(level)"
    }
    
    func displayEmotions() {
        // Размеры изображений и отступы
        let imageSize = CGSize(width: 160, height: 160)
        let horizontalSpacing: CGFloat = 30
        
        // Максимальное количество эмоций в ряду
        let maxEmotionsPerRow = min(displayedEmotions.count, 3)
        
        // Рассчитываем общую ширину ряда
        let totalWidth = CGFloat(maxEmotionsPerRow) * imageSize.width + CGFloat(maxEmotionsPerRow - 1) * horizontalSpacing
        
        // Начальная позиция (центр экрана)
        let startX = (frame.width - totalWidth) / 2 + imageSize.width / 2
        let startY = frame.height / 2 + 50 // Немного выше центра
        
        // Размещаем эмоции
        for (index, emotion) in displayedEmotions.enumerated() {
            let row = index / maxEmotionsPerRow
            let col = index % maxEmotionsPerRow
            
            let x = startX + CGFloat(col) * (imageSize.width + horizontalSpacing)
            let y = startY - CGFloat(row) * (imageSize.height + horizontalSpacing)
            
            let emotionNode = SKSpriteNode(imageNamed: emotion.0)
            emotionNode.size = imageSize
            emotionNode.position = CGPoint(x: x, y: y)
            emotionNode.name = emotion.0
            
            // Добавляем рамку
            let border = SKShapeNode(rectOf: CGSize(width: imageSize.width + 4, height: imageSize.height + 4), cornerRadius: 8)
            border.strokeColor = .darkGray
            border.lineWidth = 2
            border.position = .zero
            border.zPosition = -1
            emotionNode.addChild(border)
            
            addChild(emotionNode)
            emotionNodes.append(emotionNode)
        }
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        // Если нажата кнопка "Назад"
        if let node = atPoint(location) as? SKNode, node.name == "backButton" {
            if let view = self.view {
                let menuScene = MenuScene(size: self.size)
                menuScene.scaleMode = .aspectFill
                view.presentScene(menuScene, transition: .fade(withDuration: 0.4))
            }
            return
        }
        
        // Проверяем, нажата ли эмоция
        let tappedNodes = nodes(at: location)
        for node in tappedNodes {
            if let nodeName = node.name, node.name != "backButton" {
                // Проверяем, правильная ли эмоция выбрана
                if nodeName == currentEmotion?.0 {
                    // Правильный ответ
                    handleCorrectAnswer(node: node)
                } else {
                    // Неправильный ответ
                    handleWrongAnswer()
                }
                break
            }
        }
    }
    
    func handleCorrectAnswer(node: SKNode) {
        // Визуальное подтверждение правильного ответа
        let scaleUp = SKAction.scale(to: 1.2, duration: 0.2)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.2)
        let sequence = SKAction.sequence([scaleUp, scaleDown])
        node.run(sequence)
        
        // Обратная связь
        feedbackLabel.text = "Правильно!"
        feedbackLabel.fontColor = .systemGreen
        
        // Озвучиваем эмоцию и поощрение
        if let currentEmotion = currentEmotion {
            speak("Это \(currentEmotion.1)! Молодец!")
        }
        
        // Увеличиваем счетчик правильных ответов
        correctAnswers += 1
        
        // Проверяем, нужно ли повысить уровень
        if correctAnswers >= correctAnswersToLevelUp {
            levelUp()
        } else {
            // Запускаем новый раунд через небольшую задержку
            run(SKAction.wait(forDuration: 1.5)) {
                self.startNewRound()
            }
        }
    }
    
    func handleWrongAnswer() {
        // Обратная связь
        feedbackLabel.text = "Попробуй ещё"
        feedbackLabel.fontColor = .red
        speak("Попробуй ещё")
    }
    
    func levelUp() {
        // Поздравление
        feedbackLabel.text = "Уровень пройден!"
        feedbackLabel.fontColor = .systemGreen
        speak("Отлично! Ты переходишь на новый уровень!")
        
        // Повышаем уровень и сбрасываем счетчик
        level += 1
        correctAnswers = 0
        
        // Запускаем новый уровень через задержку
        run(SKAction.wait(forDuration: 2.0)) {
            self.startNewRound()
        }
    }
    
    func speak(_ phrase: String) {
        let utterance = AVSpeechUtterance(string: phrase)
        utterance.voice = AVSpeechSynthesisVoice(language: "ru-RU")
        utterance.rate = 0.5
        synthesizer.speak(utterance)
    }
}
