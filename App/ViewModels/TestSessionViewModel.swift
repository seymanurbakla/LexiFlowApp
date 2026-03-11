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
    
    private var studySets: [StudySet]
    private var store: StudySetStore
    
    init(studySets: [StudySet], store: StudySetStore) {
        self.studySets = studySets
        self.store = store
        generateTest()
    }
    
    var currentQuestion: Question? {
        guard currentIndex < questions.count else { return nil }
        return questions[currentIndex]
    }
    
    func generateTest() {
        var allCardsWithSets: [(Flashcard, UUID)] = []
        var allMeanings: [String] = []
        
        for set in studySets {
            for card in set.cards {
                allCardsWithSets.append((card, set.id))
                allMeanings.append(card.meaning)
            }
        }
        
        guard allCardsWithSets.count > 0 else { return }
        
        questions = allCardsWithSets.shuffled().map { item in
            let (card, setID) = item
            var options = [card.meaning]
            var otherMeanings = allMeanings.filter { $0 != card.meaning }.shuffled()
            
            // Try to get 3 other random meanings
            while options.count < 4 && !otherMeanings.isEmpty {
                options.append(otherMeanings.removeFirst())
            }
            
            return Question(card: card, studySetID: setID, options: options.shuffled(), correctAnswer: card.meaning)
        }
    }
    
    func answerCurrentQuestion(with submission: String) {
        guard let question = currentQuestion else { return }
        
        if submission == question.correctAnswer {
            score += 1
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
