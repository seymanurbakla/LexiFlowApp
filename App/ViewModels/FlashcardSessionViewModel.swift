import Foundation

class FlashcardSessionViewModel: ObservableObject {
    @Published var cardsToReview: [Flashcard] = []
    @Published var currentIndex: Int = 0
    @Published var isFinished: Bool = false
    
    private var studySet: StudySet
    private var store: StudySetStore
    private var isShuffled: Bool
    
    init(studySet: StudySet, store: StudySetStore, isShuffled: Bool) {
        self.studySet = studySet
        self.store = store
        self.isShuffled = isShuffled
        loadNextRound()
    }
    
    var currentCard: Flashcard? {
        guard currentIndex < cardsToReview.count else { return nil }
        return cardsToReview[currentIndex]
    }
    
    private func loadNextRound() {
        var nextCards = studySet.cards.filter { !$0.isKnown }
        if isShuffled {
            nextCards.shuffle()
        }
        self.cardsToReview = nextCards
        self.currentIndex = 0
        
        if self.cardsToReview.isEmpty {
            self.isFinished = true
        }
    }
    
    func swipeRight(on card: Flashcard) {
        // Mark as known in the store
        var updatedCard = card
        updatedCard.isKnown = true
        store.updateFlashcard(updatedCard, in: studySet.id)
        
        // Update local studySet to reflect changes for the next round
        if let updatedSet = store.studySets.first(where: { $0.id == studySet.id }) {
            self.studySet = updatedSet
        }
        
        advanceCard()
    }
    
    func swipeLeft(on card: Flashcard) {
        // Do nothing to the store (it's already isKnown = false). Just advance.
        advanceCard()
    }
    
    private func advanceCard() {
        currentIndex += 1
        
        if currentIndex >= cardsToReview.count {
            // End of round. Fetch next round of unknown cards.
            loadNextRound()
        }
    }
    
    func resetProgress() {
        store.resetFlashcardProgress(for: studySet.id)
        
        if let updatedSet = store.studySets.first(where: { $0.id == studySet.id }) {
            self.studySet = updatedSet
        }
        
        self.isFinished = false
        loadNextRound()
    }
}
