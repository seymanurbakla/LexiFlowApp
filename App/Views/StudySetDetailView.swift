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
                    Section(header: Text(NSLocalizedString("Study Modes", comment: ""))) {
                        Toggle(NSLocalizedString("Shuffle Cards", comment: ""), isOn: $isShuffled)
                        
                        NavigationLink(destination: FlashcardSessionView(studySet: validSet, store: store, isShuffled: isShuffled)) {
                            Label(NSLocalizedString("Flashcards", comment: ""), systemImage: "square.fill.on.square.fill")
                                .font(.headline)
                                .foregroundColor(.blue)
                        }
                        
                        NavigationLink(destination: TestSessionView(studySets: [validSet], store: store)) {
                            Label(NSLocalizedString("Test", comment: ""), systemImage: "checkmark.seal.fill")
                                .font(.headline)
                                .foregroundColor(.green)
                        }
                    }
                    
                    Section(header: Text("\(NSLocalizedString("Cards", comment: "")) (\(validSet.cards.count))")) {
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
                        Button(NSLocalizedString("Edit", comment: "")) {
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
                Text(NSLocalizedString("Study set not found.", comment: ""))
            }
        }
    }
}
