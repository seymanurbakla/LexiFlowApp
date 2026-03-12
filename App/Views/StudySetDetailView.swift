import SwiftUI

struct StudySetDetailView: View {
    @EnvironmentObject var store: StudySetStore
    @State private var showingEditSheet = false
    @State private var isShuffled = false
    let studySetID: UUID
    
    var set: StudySet? {
        store.studySets.first(where: { $0.id == studySetID })
    }
    
    var body: some View {
        Group {
            if let validSet = set {
                List {
                    Section(header: Text("Study Modes")) {
                        Toggle("Shuffle Cards", isOn: $isShuffled)
                        
                        NavigationLink(destination: FlashcardSessionView(studySet: validSet, store: store, isShuffled: isShuffled)) {
                            Label("Flashcards", systemImage: "square.fill.on.square.fill")
                                .font(.headline)
                                .foregroundColor(.blue)
                        }
                        
                        NavigationLink(destination: TestSessionView(studySets: [validSet], store: store)) {
                            Label("Test", systemImage: "checkmark.seal.fill")
                                .font(.headline)
                                .foregroundColor(.green)
                        }
                    }
                    
                    Section(header: Text("Cards (\(validSet.cards.count))")) {
                        ForEach(validSet.cards) { card in
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text(card.word)
                                        .font(.headline)
                                    Spacer()
                                    if card.isKnown {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                    }
                                }
                                
                                Text(card.meaning)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                if !card.exampleSentence.isEmpty {
                                    Text(card.exampleSentence)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                        .italic()
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
                .navigationTitle(validSet.title)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Edit") {
                            showingEditSheet = true
                        }
                    }
                }
                .sheet(isPresented: $showingEditSheet) {
                    NavigationStack {
                        EditStudySetView(studySet: validSet)
                    }
                }
            } else {
                Text("Study set not found.")
            }
        }
    }
}
