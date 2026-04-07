import SwiftUI

struct EditStudySetView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var store: StudySetStore
    
    @State var studySet: StudySet
    @State private var generatingCardID: UUID? = nil
    
    var body: some View {
        Form {
            Section(header: Text("Title")) {
                TextField("Title", text: $studySet.title)
            }
            
            Section(header: Text("Cards")) {
                ForEach($studySet.cards) { $card in
                    VStack(alignment: .leading, spacing: 16) {
                        
                        // Word Input
                        VStack(alignment: .leading, spacing: 6) {
                            Text("WORD").font(.caption).foregroundColor(.secondary).bold()
                            TextField("Enter word (e.g. Obfuscate)", text: $card.word)
                                .font(.body)
                                .padding(12)
                                .background(Color(UIColor.secondarySystemFill))
                                .cornerRadius(8)
                        }
                        
                        // Meaning Input
                        VStack(alignment: .leading, spacing: 6) {
                            Text("MEANING").font(.caption).foregroundColor(.secondary).bold()
                            TextField("Translation or definition", text: $card.meaning)
                                .font(.body)
                                .padding(12)
                                .background(Color(UIColor.secondarySystemFill))
                                .cornerRadius(8)
                        }
                        
                        // Example Sentence Input
                        VStack(alignment: .leading, spacing: 6) {
                            Text("EXAMPLE SENTENCE").font(.caption).foregroundColor(.secondary).bold()
                            
                            HStack(alignment: .top, spacing: 8) {
                                TextField("Optional example sentence", text: $card.exampleSentence, axis: .vertical)
                                    .font(.body)
                                    .padding(12)
                                    .background(Color(UIColor.secondarySystemFill))
                                    .cornerRadius(8)
                                    .lineLimit(3...8)
                                
                                if !card.word.isEmpty {
                                    Button(action: {
                                        generateSentence(for: $card)
                                    }) {
                                        if generatingCardID == card.id {
                                            ProgressView()
                                                .frame(width: 46, height: 46)
                                                .background(Color.purple.opacity(0.1))
                                                .cornerRadius(8)
                                        } else {
                                            VStack(spacing: 2) {
                                                Image(systemName: "sparkles")
                                                    .font(.system(size: 14, weight: .bold))
                                                Text("AI")
                                                    .font(.system(size: 10, weight: .bold))
                                            }
                                            .foregroundColor(.purple)
                                            .frame(width: 46, height: 46)
                                            .background(Color.purple.opacity(0.15))
                                            .cornerRadius(8)
                                        }
                                    }
                                    .buttonStyle(BorderlessButtonStyle())
                                    .disabled(generatingCardID == card.id)
                                }
                            }
                        }
                    }
                    .padding(.vertical, 8)
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
    
    private func generateSentence(for cardBinding: Binding<Flashcard>) {
        let cardID = cardBinding.wrappedValue.id
        let word = cardBinding.wrappedValue.word
        generatingCardID = cardID
        
        Task {
            do {
                let sentence = try await AIManager.shared.generateExampleSentence(for: word)
                await MainActor.run {
                    cardBinding.wrappedValue.exampleSentence = sentence
                    generatingCardID = nil
                }
            } catch {
                await MainActor.run {
                    cardBinding.wrappedValue.exampleSentence = "AI Hata: \(error.localizedDescription)"
                    generatingCardID = nil
                }
            }
        }
    }
}
