import SwiftUI

struct EditStudySetView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var store: StudySetStore
    
    @State var studySet: StudySet
    
    var body: some View {
        Form {
            Section(header: Text("Title")) {
                TextField("Title", text: $studySet.title)
            }
            
            Section(header: Text("Cards")) {
                ForEach($studySet.cards) { $card in
                    VStack(alignment: .leading) {
                        TextField("Word", text: $card.word)
                            .font(.headline)
                        TextField("Meaning", text: $card.meaning)
                            .font(.subheadline)
                        TextField("Example Sentence (Optional)", text: $card.exampleSentence)
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
                    Label("Add Card", systemImage: "plus.circle.fill")
                }
            }
        }
        .navigationTitle(studySet.title.isEmpty ? "New Study Set" : "Edit Study Set")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
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
