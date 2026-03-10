import Foundation

struct Flashcard: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var word: String
    var meaning: String
    var exampleSentence: String
    
    /// Tracks if the user "knows" this card. 
    /// If true, it won't be shown in the normal flashcard review session unless reset.
    var isKnown: Bool = false
    
    init(id: UUID = UUID(), word: String, meaning: String, exampleSentence: String = "", isKnown: Bool = false) {
        self.id = id
        self.word = word
        self.meaning = meaning
        self.exampleSentence = exampleSentence
        self.isKnown = isKnown
    }
}
