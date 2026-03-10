import Foundation

struct StudySet: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var title: String
    var cards: [Flashcard]
    
    init(id: UUID = UUID(), title: String, cards: [Flashcard] = []) {
        self.id = id
        self.title = title
        self.cards = cards
    }
}
