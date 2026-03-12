import SwiftUI

struct TestSessionView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var store: StudySetStore
    @StateObject private var viewModel: TestSessionViewModel
    
    @State private var selectedAnswer: String? = nil
    @State private var showNextButton = false
    
    init(studySets: [StudySet], store: StudySetStore) {
        _viewModel = StateObject(wrappedValue: TestSessionViewModel(studySets: studySets, store: store))
    }
    
    var body: some View {
        VStack {
            if viewModel.isFinished {
                VStack(spacing: 20) {
                    Text(NSLocalizedString("Test Complete!", comment: ""))
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("\(NSLocalizedString("Score", comment: "" || "Score")): \(viewModel.score) / \(viewModel.questions.count)")
                        .font(.title2)
                    
                    Text(NSLocalizedString("Incorrect answers have been added back to your flashcard review stack.", comment: ""))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding()
                    
                    Button(NSLocalizedString("Done", comment: "")) {
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                }
            } else if let question = viewModel.currentQuestion {
                VStack(spacing: 20) {
                    Text("\(NSLocalizedString("Question", comment: "" || "Question")) \(viewModel.currentIndex + 1) \(NSLocalizedString("of", comment: "" || "of")) \(viewModel.questions.count)")
                        .font(.headline)
                        .padding(.top)
                    
                    ProgressView(value: Double(viewModel.currentIndex), total: Double(viewModel.questions.count))
                        .padding(.horizontal)
                        .padding(.bottom)
                    
                    Text(NSLocalizedString("What is the meaning of:", comment: ""))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(question.card.word)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.bottom, 30)
                    
                    ForEach(question.options, id: \.self) { option in
                        Button(action: {
                            if !showNextButton {
                                selectedAnswer = option
                                showNextButton = true
                            }
                        }) {
                            Text(option)
                                .font(.body)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(buttonColor(for: option, correctAnswer: question.correctAnswer))
                                .foregroundColor(selectedAnswer == option || (showNextButton && option == question.correctAnswer) ? .white : .primary)
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                        }
                        .disabled(showNextButton)
                    }
                    
                    Spacer()
                    
                    if showNextButton {
                        Button(NSLocalizedString("Next", comment: "")) {
                            viewModel.answerCurrentQuestion(with: selectedAnswer ?? "")
                            selectedAnswer = nil
                            showNextButton = false
                        }
                        .buttonStyle(.borderedProminent)
                        .frame(maxWidth: .infinity)
                        .padding()
                    }
                }
                .padding()
            } else {
                Text(NSLocalizedString("Not enough cards to generate a test.", comment: ""))
            }
        }
        .navigationTitle(NSLocalizedString("Test", comment: ""))
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if let firstSet = store.studySets.first(where: { set in viewModel.questions.contains(where: { $0.card.id == set.cards.first?.id }) }) {
               _ = firstSet // dummy call
            }
            // Real environment inject
            let currentSet = viewModel.currentQuestion?.card.id != nil ? viewModel.currentQuestion : nil
            _ = currentSet
        }
    }
    
    private func buttonColor(for option: String, correctAnswer: String) -> Color {
        if !showNextButton {
            return Color(UIColor.systemBackground) // default
        }
        
        if option == correctAnswer {
            return .green // Correct answer always shown as green after an answer is selected
        }
        
        if selectedAnswer == option {
            return .red // Selected wrong answer
        }
        
        return Color(UIColor.systemBackground) // other wrong answers stay default
    }
}
