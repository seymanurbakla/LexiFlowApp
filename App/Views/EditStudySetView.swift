import SwiftUI

struct EditStudySetView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var store: StudySetStore
    
    @State var studySet: StudySet
    
    var body: some View {
        Form {
            Section(header: Text(NSLocalizedString("Title", comment: ""))) {
                TextField(NSLocalizedString("Title", comment: ""), text: $studySet.title)
            }
            
            Section(header: Text(NSLocalizedString("Cards", comment: ""))) {
                ForEach($studySet.cards) { $card in
                    VStack(alignment: .leading) {
                        TextField(NSLocalizedString("Word", comment: ""), text: $card.word)
                            .font(.headline)
                        TextField(NSLocalizedString("Meaning", comment: ""), text: $card.meaning)
                            .font(.subheadline)
                        TextField(NSLocalizedString("Example Sentence (Optional)", comment: ""), text: $card.exampleSentence)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                .onDelete { indexSet in
                    studySet.cards.remove(atOffsets: indexSet)
                }
                
                Button(action: {
                    studySet.cards.append(Flashcard(word: "", meaning: ""))
                }) {
                    Label(NSLocalizedString("Add Card", comment: ""), systemImage: "plus.circle.fill")
                }
            }
        }
        .navigationTitle(studySet.title.isEmpty ? NSLocalizedString("New Study Set", comment: "") : NSLocalizedString("Edit Study Set", comment: ""))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(NSLocalizedString("Cancel", comment: "")) { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button(NSLocalizedString("Save", comment: "")) {
                    saveSet()
                    dismiss()
                }
                .disabled(studySet.title.isEmpty || studySet.cards.isEmpty)
            }
        }
    }
    
    private func saveSet() {
        if store.studySets.contains(where: { $0.id == studySet.id }) {
            store.updateStudySet(studySet)
        } else {
            store.addStudySet(studySet)
        }
    }
}
