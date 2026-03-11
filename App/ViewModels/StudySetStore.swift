import Foundation
import SwiftUI

class StudySetStore: ObservableObject {
    @Published var studySets: [StudySet] = [] {
        didSet {
            saveToLocal()
        }
    }
    
    private let fileName = "lexiflow_data.json"
    
    init() {
        loadFromLocal()
        
        // If empty after loading, add some samples
        if studySets.isEmpty {
            studySets = [
                StudySet(title: "Spanish Basics", cards: [
                    Flashcard(word: "Hola", meaning: "Hello", exampleSentence: "Hola, ¿cómo estás?"),
                    Flashcard(word: "Adiós", meaning: "Goodbye", exampleSentence: "Adiós, hasta mañana."),
                    Flashcard(word: "Por favor", meaning: "Please", exampleSentence: "¿Me ayudas, por favor?"),
                    Flashcard(word: "Gracias", meaning: "Thank you", exampleSentence: "Gracias por tu ayuda.")
                ]),
                StudySet(title: "Swift Concepts", cards: [
                    Flashcard(word: "Struct", meaning: "A value type in Swift used to encapsulate related properties and behaviors.", exampleSentence: "Structs are passed by value."),
                    Flashcard(word: "Class", meaning: "A reference type in Swift.", exampleSentence: "Classes support inheritance."),
                    Flashcard(word: "Protocol", meaning: "Defines a blueprint of methods, properties, and other requirements.", exampleSentence: "A struct can conform to multiple protocols.")
                ])
            ]
        }
    }
    
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    private func saveToLocal() {
        let url = getDocumentsDirectory().appendingPathComponent(fileName)
        do {
            let data = try JSONEncoder().encode(studySets)
            try data.write(to: url, options: [.atomicWrite, .completeFileProtection])
        } catch {
            print("Could not save data: \(error.localizedDescription)")
        }
    }
    
    private func loadFromLocal() {
        let url = getDocumentsDirectory().appendingPathComponent(fileName)
        guard FileManager.default.fileExists(atPath: url.path) else { return }
        
        do {
            let data = try Data(contentsOf: url)
            studySets = try JSONDecoder().decode([StudySet].self, from: data)
        } catch {
            print("Could not load data: \(error.localizedDescription)")
        }
    }
    
    func addStudySet(_ set: StudySet) {
        studySets.append(set)
    }
    
    func updateStudySet(_ updatedSet: StudySet) {
        if let index = studySets.firstIndex(where: { $0.id == updatedSet.id }) {
            studySets[index] = updatedSet
        }
    }
    
    func deleteStudySet(_ set: StudySet) {
        studySets.removeAll { $0.id == set.id }
    }
    
    func updateFlashcard(_ card: Flashcard, in setID: UUID) {
        if let setIndex = studySets.firstIndex(where: { $0.id == setID }) {
            if let cardIndex = studySets[setIndex].cards.firstIndex(where: { $0.id == card.id }) {
                studySets[setIndex].cards[cardIndex] = card
                self.objectWillChange.send()
                saveToLocal()
            }
        }
    }
    
    func resetFlashcardProgress(for setID: UUID) {
        if let setIndex = studySets.firstIndex(where: { $0.id == setID }) {
            for i in 0..<studySets[setIndex].cards.count {
                studySets[setIndex].cards[i].isKnown = false
            }
            self.objectWillChange.send()
            saveToLocal()
        }
    }
}
