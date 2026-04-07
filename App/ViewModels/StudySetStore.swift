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
    
    private func saveToLocal() {
        StorageManager.shared.save(studySets, to: fileName)
    }
    
    private func loadFromLocal() {
        if let loadedSets = StorageManager.shared.load([StudySet].self, from: fileName) {
            studySets = loadedSets
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
    
    // MARK: - Export / Import
    
    func getExportURL() -> URL? {
        let tempFile = FileManager.default.temporaryDirectory.appendingPathComponent("LexiFlow_Backup.json")
        do {
            let data = try JSONEncoder().encode(studySets)
            try data.write(to: tempFile, options: .atomicWrite)
            return tempFile
        } catch {
            print("Export error: \(error)")
            return nil
        }
    }
    
    func importData(from url: URL) {
        // Attempt to access security scoped resource if coming from File Importer
        let isAccessing = url.startAccessingSecurityScopedResource()
        defer {
            if isAccessing {
                url.stopAccessingSecurityScopedResource()
            }
        }
        
        do {
            let data = try Data(contentsOf: url)
            let importedSets = try JSONDecoder().decode([StudySet].self, from: data)
            DispatchQueue.main.async {
                // Merge current sets with imported sets without exact duplicating by ID
                var currentSets = self.studySets
                for newSet in importedSets {
                    if let index = currentSets.firstIndex(where: { $0.id == newSet.id }) {
                        currentSets[index] = newSet // Update existing
                    } else {
                        currentSets.append(newSet) // Add new
                    }
                }
                self.studySets = currentSets
            }
        } catch {
            print("Import failed: \(error)")
        }
    }
}
