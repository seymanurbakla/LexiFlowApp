import Foundation

struct Question: Identifiable {
    let id = UUID()
    let card: Flashcard
    let studySetID: UUID
    let options: [String]
    let correctAnswer: String
}

class TestSessionViewModel: ObservableObject {
    @Published var questions: [Question] = []
    @Published var currentIndex = 0
    @Published var score = 0
    @Published var isFinished = false
    @Published var isLoadingAI = false
    
    private var studySets: [StudySet]
    private var store: StudySetStore
    private var isHardMode: Bool
    
    init(studySets: [StudySet], store: StudySetStore, isHardMode: Bool = false) {
        self.studySets = studySets
        self.store = store
        self.isHardMode = isHardMode
        
        Task {
            await generateTest()
        }
    }
    
    var currentQuestion: Question? {
        guard currentIndex < questions.count else { return nil }
        return questions[currentIndex]
    }
    
    @MainActor
    func generateTest() async {
        if isHardMode {
            isLoadingAI = true
        }
        
        var allCardsWithSets: [(Flashcard, UUID)] = []
        var allMeanings: [String] = []
        var wordsDict: [String: String] = [:] // Used for AI
        
        for set in studySets {
            for card in set.cards {
                allCardsWithSets.append((card, set.id))
                allMeanings.append(card.meaning)
                wordsDict[card.word] = card.meaning
            }
        }
        
        guard allCardsWithSets.count > 0 else {
            if isHardMode { isLoadingAI = false }
            return
        }
        
        var aiDistractors: [String: [String]] = [:]
        
        if isHardMode {
            // Ask AI to generate distractors for the entire batch
            do {
                aiDistractors = try await AIManager.shared.generateTrickyDistractors(for: wordsDict)
            } catch {
                print("Failed to load AI Distractors, falling back to normal mode: \(error)")
                self.isHardMode = false // Fallback
            }
        }
        
        let shuffledCards = allCardsWithSets.shuffled()
        var newQuestions: [Question] = []
        
        for item in shuffledCards {
            let (card, setID) = item
            var options = [card.meaning]
            
            if isHardMode, let distractors = aiDistractors[card.word], distractors.count >= 3 {
                // Use AI Distractors
                let selectedDistractors = Array(distractors.prefix(3))
                options.append(contentsOf: selectedDistractors)
            } else {
                // Fallback / Standard mode: pull random meanings from the rest of the cards
                var otherMeanings = allMeanings.filter { $0 != card.meaning }.shuffled()
                while options.count < 4 && !otherMeanings.isEmpty {
                    options.append(otherMeanings.removeFirst())
                }
            }
            
            newQuestions.append(Question(card: card, studySetID: setID, options: options.shuffled(), correctAnswer: card.meaning))
        }
        
        self.questions = newQuestions
        if isHardMode {
            self.isLoadingAI = false
        }
    }
    
    func answerCurrentQuestion(with submission: String) {
        guard let question = currentQuestion else { return }
        
        if submission == question.correctAnswer {
            score += 1
            StatsManager.shared.logWordLearned()
            StatsManager.shared.logStudySession()
        } else {
            // Incorrect answer. Mark as "don't know" so it appears in flashcards again.
            var updatedCard = question.card
            updatedCard.isKnown = false
            store.updateFlashcard(updatedCard, in: question.studySetID)
        }
        
        if currentIndex < questions.count - 1 {
            currentIndex += 1
        } else {
            isFinished = true
        }
    }
}
