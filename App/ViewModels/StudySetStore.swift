import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth
import Combine

class StudySetStore: ObservableObject {
    @Published var studySets: [StudySet] = []
    
    private var db = Firestore.firestore()
    private var listenerRegistration: ListenerRegistration?
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Listen to auth state changes to load data for the correct user
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            if let user = user {
                self?.startListening(for: user.uid)
            } else {
                self?.stopListening()
                self?.studySets = []
            }
        }
    }
    
    private var userStudySetsCollection: CollectionReference? {
        guard let uid = Auth.auth().currentUser?.uid else { return nil }
        return db.collection("users").document(uid).collection("studySets")
    }
    
    private func startListening(for uid: String) {
        stopListening()
        
        listenerRegistration = db.collection("users").document(uid).collection("studySets")
            .addSnapshotListener { [weak self] querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching study sets: \(String(describing: error))")
                    return
                }
                
                self?.studySets = documents.compactMap { document in
                    try? document.data(as: StudySet.self)
                }
            }
    }
    
    private func stopListening() {
        listenerRegistration?.remove()
        listenerRegistration = nil
    }
    
    func addStudySet(_ set: StudySet) {
        guard let collection = userStudySetsCollection else { return }
        do {
            try collection.document(set.id.uuidString).setData(from: set)
        } catch {
            print("Error adding study set: \(error)")
        }
    }
    
    func updateStudySet(_ updatedSet: StudySet) {
        guard let collection = userStudySetsCollection else { return }
        do {
            try collection.document(updatedSet.id.uuidString).setData(from: updatedSet)
        } catch {
            print("Error updating study set: \(error)")
        }
    }
    
    func deleteStudySet(_ set: StudySet) {
        guard let collection = userStudySetsCollection else { return }
        collection.document(set.id.uuidString).delete { error in
            if let error = error {
                print("Error deleting study set: \(error)")
            }
        }
    }
    
    func updateFlashcard(_ card: Flashcard, in setID: UUID) {
        // Local fast update to avoid UI jitter before network returns
        if let setIndex = studySets.firstIndex(where: { $0.id == setID }) {
            if let cardIndex = studySets[setIndex].cards.firstIndex(where: { $0.id == card.id }) {
                studySets[setIndex].cards[cardIndex] = card
                self.objectWillChange.send()
                
                // Write the whole updated set back to Firestore
                let updatedSet = studySets[setIndex]
                updateStudySet(updatedSet)
            }
        }
    }
    
    func resetFlashcardProgress(for setID: UUID) {
        if let setIndex = studySets.firstIndex(where: { $0.id == setID }) {
            var updatedSet = studySets[setIndex]
            for i in 0..<updatedSet.cards.count {
                updatedSet.cards[i].isKnown = false
            }
            
            // Fast local update
            studySets[setIndex] = updatedSet
            self.objectWillChange.send()
            
            // Network update
            updateStudySet(updatedSet)
        }
    }
}
