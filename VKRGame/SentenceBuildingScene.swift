import SpriteKit
import AVFoundation

class SentenceBuildingScene: SKScene {
    // Структура для предложения
    struct Sentence {
        let words: [String]
        let images: [String]
        let audioDescriptions: [String]
        
        var fullSentence: String {
            return words.joined(separator: " ")
        }
    }
    
    // Доступные предложения
    let sentences: [Sentence] = [
        Sentence(
            words: ["Мальчик", "ест", "яблоко"],
            images: ["boy", "eating", "apple"],
            audioDescriptions: ["Мальчик", "ест", "яблоко"]
        ),
        Sentence(
            words: ["Кошка", "пьёт", "молоко"],
            images: ["cat", "drinking", "milk"],
            audioDescriptions: ["Кошка", "пьёт", "молоко"]
        ),
        Sentence(
            words: ["Собака", "играет", "с", "мячом"],
            images: ["dog", "playing", "with", "ball"],
            audioDescriptions: ["Собака", "играет", "со", "мячом"]
        ),
        Sentence(
            words: ["Девочка", "рисует", "цветок"],
            images: ["girl", "drawing", "flower"],
            audioDescriptions: ["Девочка", "рисует", "цветок"]
        )
    ]
    
    // Текущее предложение
    var currentSentence: Sentence?
    
    // Перемешанные слова текущего предложения
    var shuffledWords: [(index: Int, word: String, image: String, description: String)] = []
    
    // Ячейки для составления предложения
    var sentenceCells: [SKSpriteNode] = []
    
    // Карточки со словами
    var wordCards: [SKSpriteNode] = []
    
    // Перетаскиваемая карточка
    var selectedCard: SKSpriteNode?
    var touchOffset: CGPoint = .zero
    
    // UI элементы
    var titleLabel: SKLabelNode!
    var instructionLabel: SKLabelNode!
    var feedbackLabel: SKLabelNode!
    var sentenceLabel: SKLabelNode!
    var levelLabel: SKLabelNode!
    
    // Синтезатор речи
    let synthesizer = AVSpeechSynthesizer()
    
    // Уровень игры
    var level = 1
    
    // Счетчик правильных ответов на текущем уровне
    var correctSentences = 0
    
    // Количество правильных ответов, необходимых для перехода на следующий уровень
    let correctSentencesToLevelUp = 3
    
    override func didMove(to view: SKView) {
        backgroundColor = .white
        setupUI()
        startNewRound()
    }
    
    func setupUI() {
        // Заголовок
        titleLabel = SKLabelNode(text: "Составь предложение")
        titleLabel.fontName = "AvenirNext-Bold"
        titleLabel.fontSize = 32
        titleLabel.fontColor = .black
        titleLabel.position = CGPoint(x: frame.midX, y: frame.height - 60)
        titleLabel.zPosition = 5
        addChild(titleLabel)
        
        // Инструкция
        instructionLabel = SKLabelNode(text: "Составь предложение из картинок")
        instructionLabel.fontName = "AvenirNext-Regular"
        instructionLabel.fontSize = 26
        instructionLabel.fontColor = .darkGray
        instructionLabel.position = CGPoint(x: frame.midX, y: frame.height - 100)
        instructionLabel.zPosition = 5
        addChild(instructionLabel)
        
        // Индикатор уровня
        levelLabel = SKLabelNode(text: "Уровень \(level)")
        levelLabel.fontName = "AvenirNext-Bold"
        levelLabel.fontSize = 24
        levelLabel.fontColor = .darkGray
        levelLabel.position = CGPoint(x: frame.width - 90, y: frame.height - 40)
        levelLabel.zPosition = 5
        addChild(levelLabel)
        
        // Текущее составленное предложение
        sentenceLabel = SKLabelNode(text: "")
        sentenceLabel.fontName = "AvenirNext-Bold"
        sentenceLabel.fontSize = 26
        sentenceLabel.fontColor = .systemBlue
        sentenceLabel.position = CGPoint(x: frame.midX, y: frame.height / 2 - 50)
        sentenceLabel.zPosition = 5
        addChild(sentenceLabel)
        
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
        
        // Кнопка проверки
        addCheckButton()
        
        // Кнопка озвучивания
        addSpeakButton()
        
        // Озвучиваем инструкцию
        speak("Составь предложение из картинок")
    }
    
    func startNewRound() {
        // Очищаем предыдущее предложение
        clearPreviousRound()
        
        // Выбираем предложение в зависимости от уровня
        var availableSentences = sentences
        if level < 3 {
            // На начальных уровнях используем только короткие предложения (3 слова)
            availableSentences = sentences.filter { $0.words.count <= 3 }
        }
        
        // Выбираем случайное предложение
        if let sentence = availableSentences.randomElement() {
            currentSentence = sentence
            
            // Создаем перемешанную версию предложения
            createShuffledSentence(sentence: sentence)
            
            // Создаем ячейки для составления предложения
            createSentenceCells(count: sentence.words.count)
            
            // Создаем карточки со словами
            createWordCards()
        }
        
        // Обновляем отображение уровня
        levelLabel.text = "Уровень \(level)"
    }
    
    func clearPreviousRound() {
        // Удаляем ячейки
        for cell in sentenceCells {
            cell.removeFromParent()
        }
        sentenceCells.removeAll()
        
        // Удаляем карточки
        for card in wordCards {
            card.removeFromParent()
        }
        wordCards.removeAll()
        
        // Сбрасываем состояние игры
        shuffledWords.removeAll()
        selectedCard = nil
        sentenceLabel.text = ""
        feedbackLabel.text = ""
    }
    
    func createShuffledSentence(sentence: Sentence) {
        // Создаем массив с индексами, словами, изображениями и описаниями
        var sentenceElements: [(index: Int, word: String, image: String, description: String)] = []
        
        for i in 0..<sentence.words.count {
            sentenceElements.append((i, sentence.words[i], sentence.images[i], sentence.audioDescriptions[i]))
        }
        
        // Перемешиваем элементы предложения
        shuffledWords = sentenceElements.shuffled()
    }
    
    func createSentenceCells(count: Int) {
        // Размер ячейки и отступы
        let cellSize = calculateCellSize(count: count)
        let spacing: CGFloat = 15
        
        // Рассчитываем общую ширину ряда ячеек
        let totalWidth = CGFloat(count) * cellSize.width + CGFloat(count - 1) * spacing
        
        // Начальная позиция (центр экрана)
        let startX = (frame.width - totalWidth) / 2 + cellSize.width / 2
        let startY = frame.height / 2 + 50
        
        // Создаем ячейки
        for i in 0..<count {
            let x = startX + CGFloat(i) * (cellSize.width + spacing)
            
            let cell = SKSpriteNode(color: .systemGray5, size: cellSize)
            cell.position = CGPoint(x: x, y: startY)
            cell.name = "cell_\(i)"
            
            // Добавляем рамку
            let border = SKShapeNode(rectOf: CGSize(width: cellSize.width + 4, height: cellSize.height + 4), cornerRadius: 8)
            border.strokeColor = .darkGray
            border.lineWidth = 2
            border.position = .zero
            border.zPosition = -1
            cell.addChild(border)
            
            // Добавляем номер ячейки
            let numberLabel = SKLabelNode(text: "\(i + 1)")
            numberLabel.fontName = "AvenirNext-Bold"
            numberLabel.fontSize = 20
            numberLabel.fontColor = .darkGray
            numberLabel.position = CGPoint(x: 0, y: -cellSize.height/2 - 20)
            cell.addChild(numberLabel)
            
            addChild(cell)
            sentenceCells.append(cell)
            
            // Сохраняем, какой элемент должен быть в этой ячейке
            cell.userData = NSMutableDictionary()
            cell.userData?.setValue(i, forKey: "correctIndex")
            cell.userData?.setValue(nil, forKey: "placedCardNode")
        }
    }
    
    func createWordCards() {
        // Размер карточки и отступы
        let cardSize = calculateCellSize(count: shuffledWords.count)
        let spacing: CGFloat = 15
        
        // Рассчитываем общую ширину ряда карточек
        let totalWidth = CGFloat(shuffledWords.count) * cardSize.width + CGFloat(shuffledWords.count - 1) * spacing
        
        // Начальная позиция (центр экрана, ниже ячеек)
        let startX = (frame.width - totalWidth) / 2 + cardSize.width / 2
        let startY = frame.height / 2 - 150
        
        // Создаем карточки со словами
        for (i, element) in shuffledWords.enumerated() {
            let x = startX + CGFloat(i) * (cardSize.width + spacing)
            
            let card = SKSpriteNode(imageNamed: element.image)
            card.size = cardSize
            card.position = CGPoint(x: x, y: startY)
            card.name = "card_\(i)"
            
            // Добавляем рамку
            let border = SKShapeNode(rectOf: CGSize(width: cardSize.width + 4, height: cardSize.height + 4), cornerRadius: 8)
            border.strokeColor = .systemBlue
            border.lineWidth = 2
            border.position = .zero
            border.zPosition = -1
            card.addChild(border)
            
            // Добавляем слово под карточкой
            let wordLabel = SKLabelNode(text: element.word)
            wordLabel.fontName = "AvenirNext-Bold"
            wordLabel.fontSize = 18
            wordLabel.fontColor = .black
            wordLabel.position = CGPoint(x: 0, y: -cardSize.height/2 - 15)
            card.addChild(wordLabel)
            
            // Сохраняем информацию о карточке
            card.userData = NSMutableDictionary()
            card.userData?.setValue(element.index, forKey: "sentenceIndex")
            card.userData?.setValue(element.word, forKey: "word")
            card.userData?.setValue(element.description, forKey: "description")
            card.userData?.setValue(nil, forKey: "placedInCell")
            
            addChild(card)
            wordCards.append(card)
        }
    }
    
    func calculateCellSize(count: Int) -> CGSize {
        // Рассчитываем размер ячейки/карточки в зависимости от количества элементов
        let maxWidth = frame.width * 0.8 // Используем 80% ширины экрана
        let spacing: CGFloat = 15
        
        // Вычисляем максимальную ширину одной ячейки
        let maxCellWidth = (maxWidth - CGFloat(count - 1) * spacing) / CGFloat(count)
        
        // Ограничиваем размер ячейки
        let cellWidth = min(maxCellWidth, 120)
        let cellHeight = cellWidth
        
        return CGSize(width: cellWidth, height: cellHeight)
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
    
    func addCheckButton() {
        let button = SKShapeNode(rectOf: CGSize(width: 120, height: 40), cornerRadius: 12)
        button.fillColor = .systemGreen
        button.name = "checkButton"
        button.position = CGPoint(x: frame.midX - 70, y: 120)
        button.zPosition = 2
        addChild(button)

        let label = SKLabelNode(text: "Проверить")
        label.fontName = "AvenirNext-Bold"
        label.fontSize = 20
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        label.position = .zero
        label.name = "checkButton"
        button.addChild(label)
    }
    
    func addSpeakButton() {
        let button = SKShapeNode(rectOf: CGSize(width: 120, height: 40), cornerRadius: 12)
        button.fillColor = .systemBlue
        button.name = "speakButton"
        button.position = CGPoint(x: frame.midX + 70, y: 120)
        button.zPosition = 2
        addChild(button)

        let label = SKLabelNode(text: "Озвучить")
        label.fontName = "AvenirNext-Bold"
        label.fontSize = 20
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        label.position = .zero
        label.name = "speakButton"
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
        
        // Если нажата кнопка "Проверить"
        if let node = atPoint(location) as? SKNode, node.name == "checkButton" {
            checkSentence()
            return
        }
        
        // Если нажата кнопка "Озвучить"
        if let node = atPoint(location) as? SKNode, node.name == "speakButton" {
            speakCurrentSentence()
            return
        }
        
        // Проверяем, нажата ли карточка
        for node in nodes(at: location) {
            if let spriteName = node.name, spriteName.hasPrefix("card_"), let spriteNode = node as? SKSpriteNode {
                // Если карточка уже размещена в ячейке, сначала извлекаем её
                if let cellNode = spriteNode.userData?.value(forKey: "placedInCell") as? SKSpriteNode {
                    cellNode.userData?.setValue(nil, forKey: "placedCardNode")
                    spriteNode.userData?.setValue(nil, forKey: "placedInCell")
                }
                
                // Начинаем перетаскивание
                selectedCard = spriteNode
                touchOffset = CGPoint(x: location.x - spriteNode.position.x, y: location.y - spriteNode.position.y)
                
                // Озвучиваем слово
                if let description = spriteNode.userData?.value(forKey: "description") as? String {
                    speak(description)
                }
                
                // Поднимаем карточку наверх
                spriteNode.zPosition = 10
                
                break
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let selectedCard = selectedCard else { return }
        
        // Перемещаем карточку вместе с пальцем
        let location = touch.location(in: self)
        selectedCard.position = CGPoint(
            x: location.x - touchOffset.x,
            y: location.y - touchOffset.y
        )
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let selectedCard = selectedCard else { return }
        
        let location = touch.location(in: self)
        
        // Проверяем, находится ли карточка над ячейкой
        var droppedInCell = false
        
        for cell in sentenceCells {
            if cell.frame.contains(location) {
                // Проверяем, не занята ли ячейка
                if cell.userData?.value(forKey: "placedCardNode") == nil {
                    // Помещаем карточку в ячейку
                    droppedInCell = true
                    placeCardInCell(card: selectedCard, cell: cell)
                    updateSentenceLabel()
                    break
                }
            }
        }
        
        // Если карточка не попала в ячейку, возвращаем её на исходное место
        if !droppedInCell {
            returnCardToStartPosition()
        }
        
        // Сбрасываем выбранную карточку
        self.selectedCard?.zPosition = 1
        self.selectedCard = nil
    }
    
    func placeCardInCell(card: SKSpriteNode, cell: SKSpriteNode) {
        // Перемещаем карточку в центр ячейки
        let moveAction = SKAction.move(to: cell.position, duration: 0.2)
        card.run(moveAction)
        
        // Обновляем связи между карточкой и ячейкой
        card.userData?.setValue(cell, forKey: "placedInCell")
        cell.userData?.setValue(card, forKey: "placedCardNode")
    }
    
    func returnCardToStartPosition() {
        guard let selectedCard = selectedCard else { return }
        
        // Получаем индекс из имени карточки
        if let nodeName = selectedCard.name, nodeName.hasPrefix("card_"),
           let indexStr = nodeName.split(separator: "_").last,
           let index = Int(indexStr),
           index < shuffledWords.count {
            
            // Вычисляем исходную позицию
            let cardSize = calculateCellSize(count: shuffledWords.count)
            let spacing: CGFloat = 15
            let totalWidth = CGFloat(shuffledWords.count) * cardSize.width + CGFloat(shuffledWords.count - 1) * spacing
            let startX = (frame.width - totalWidth) / 2 + cardSize.width / 2
            let startY = frame.height / 2 - 150
            
            let x = startX + CGFloat(index) * (cardSize.width + spacing)
            let originalPosition = CGPoint(x: x, y: startY)
            
            // Анимируем возврат
            let moveAction = SKAction.move(to: originalPosition, duration: 0.2)
            selectedCard.run(moveAction)
        }
    }
    
    func updateSentenceLabel() {
        // Собираем текущее предложение на основе размещенных карточек
        var sentenceWords: [String?] = Array(repeating: nil, count: sentenceCells.count)
        
        for cell in sentenceCells {
            if let cellIndex = Int(cell.name?.split(separator: "_").last ?? "0"),
               let placedCard = cell.userData?.value(forKey: "placedCardNode") as? SKSpriteNode,
               let word = placedCard.userData?.value(forKey: "word") as? String {
                sentenceWords[cellIndex] = word
            }
        }
        
        // Проверяем, все ли ячейки заполнены
        if !sentenceWords.contains(nil) {
            // Формируем предложение
            let sentenceText = sentenceWords.compactMap { $0 }.joined(separator: " ")
            sentenceLabel.text = sentenceText
        } else {
            sentenceLabel.text = ""
        }
    }
    
    func checkSentence() {
        // Проверяем, все ли ячейки заполнены
        let allCellsFilled = sentenceCells.allSatisfy { $0.userData?.value(forKey: "placedCardNode") != nil }
        
        if !allCellsFilled {
            // Если не все ячейки заполнены, показываем сообщение
            feedbackLabel.text = "Заполни все ячейки"
            feedbackLabel.fontColor = .red
            speak("Заполни все ячейки")
            return
        }
        
        // Проверяем правильность предложения
        var isCorrect = true
        
        for cell in sentenceCells {
            if let correctIndex = cell.userData?.value(forKey: "correctIndex") as? Int,
               let placedCard = cell.userData?.value(forKey: "placedCardNode") as? SKSpriteNode,
               let cardIndex = placedCard.userData?.value(forKey: "sentenceIndex") as? Int {
                
                if correctIndex != cardIndex {
                    isCorrect = false
                    break
                }
            }
        }
        
        if isCorrect {
            // Правильное предложение
            handleCorrectSentence()
        } else {
            // Неправильное предложение
            handleWrongSentence()
        }
    }
    
    func handleCorrectSentence() {
        // Визуальное подтверждение правильного ответа
        feedbackLabel.text = "Правильно!"
        feedbackLabel.fontColor = .systemGreen
        
        // Озвучиваем предложение
        speakCurrentSentence()
        
        // Анимация для всех ячеек
        for cell in sentenceCells {
            let scaleUp = SKAction.scale(to: 1.1, duration: 0.2)
            let scaleDown = SKAction.scale(to: 1.0, duration: 0.2)
            let sequence = SKAction.sequence([scaleUp, scaleDown])
            cell.run(sequence)
        }
        
        // Увеличиваем счетчик правильных ответов
        correctSentences += 1
        
        // Проверяем, нужно ли повысить уровень
        if correctSentences >= correctSentencesToLevelUp {
            levelUp()
        } else {
            // Запускаем новый раунд через небольшую задержку
            run(SKAction.wait(forDuration: 2.0)) {
                self.startNewRound()
            }
        }
    }
    
    func handleWrongSentence() {
        // Обратная связь
        feedbackLabel.text = "Попробуй ещё"
        feedbackLabel.fontColor = .red
        speak("Попробуй ещё")
        
        // Анимация для всех ячеек (легкое дрожание)
        for cell in sentenceCells {
            let moveRight = SKAction.moveBy(x: 5, y: 0, duration: 0.05)
            let moveLeft = SKAction.moveBy(x: -10, y: 0, duration: 0.1)
            let moveCenter = SKAction.moveBy(x: 5, y: 0, duration: 0.05)
            let sequence = SKAction.sequence([moveRight, moveLeft, moveCenter])
            cell.run(sequence)
        }
    }
    
    func speakCurrentSentence() {
        if !sentenceLabel.text!.isEmpty {
            speak(sentenceLabel.text!)
        } else if let currentSentence = currentSentence {
            // Если метка пуста, но предложение выбрано, озвучиваем образец предложения
            speak(currentSentence.fullSentence)
        }
    }
    
    func levelUp() {
        // Поздравление
        feedbackLabel.text = "Уровень пройден!"
        feedbackLabel.fontColor = .systemGreen
        speak("Отлично! Ты переходишь на новый уровень!")
        
        // Повышаем уровень и сбрасываем счетчик
        level += 1
        correctSentences = 0
        
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
