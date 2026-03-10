import Foundation

struct Question: Identifiable {
    let id = UUID()
    let card: Flashcard
    let options: [String]
    let correctAnswer: String
}

class TestSessionViewModel: ObservableObject {
    @Published var questions: [Question] = []
    @Published var currentIndex = 0
    @Published var score = 0
    @Published var isFinished = false
    
    private var studySet: StudySet
    private var store: StudySetStore
    
    init(studySet: StudySet, store: StudySetStore) {
        self.studySet = studySet
        self.store = store
        generateTest()
    }
    
    var currentQuestion: Question? {
        guard currentIndex < questions.count else { return nil }
        return questions[currentIndex]
    }
    
    func generateTest() {
        guard studySet.cards.count > 0 else { return }
        
        let allMeanings = studySet.cards.map { $0.meaning }
        
        questions = studySet.cards.shuffled().map { card in
            var options = [card.meaning]
            var otherMeanings = allMeanings.filter { $0 != card.meaning }.shuffled()
            
            // Try to get 3 other random meanings
            while options.count < 4 && !otherMeanings.isEmpty {
                options.append(otherMeanings.removeFirst())
            }
            
            return Question(card: card, options: options.shuffled(), correctAnswer: card.meaning)
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
            store.updateFlashcard(updatedCard, in: studySet.id)
        }
        
        if currentIndex < questions.count - 1 {
            currentIndex += 1
        } else {
            isFinished = true
        }
    }
}
