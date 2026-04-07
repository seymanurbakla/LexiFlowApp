import SwiftUI

struct TestSessionView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var store: StudySetStore
    @StateObject private var viewModel: TestSessionViewModel
    
    @State private var selectedAnswer: String? = nil
    @State private var showNextButton = false
    
    init(studySets: [StudySet], store: StudySetStore, isHardMode: Bool = false) {
        _viewModel = StateObject(wrappedValue: TestSessionViewModel(studySets: studySets, store: store, isHardMode: isHardMode))
    }
    
    var body: some View {
        VStack {
            if viewModel.isLoadingAI {
                VStack(spacing: 20) {
                    ProgressView()
                        .scaleEffect(1.5)
                        .padding()
                    
                    Text("AI is crafting tricky questions...")
                        .font(.headline)
                        .foregroundColor(.blue)
                        
                    Text("Preparing the ultimate challenge for \(viewModel.questions.count) words.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            } else if viewModel.isFinished {
                VStack(spacing: 20) {
                    Text("Test Complete!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Score: \(viewModel.score) / \(viewModel.questions.count)")
                        .font(.title2)
                    
                    Text("Incorrect answers have been added back to your flashcard review stack.")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding()
                    
                    Button("Done") {
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                }
            } else if let question = viewModel.currentQuestion {
                VStack(spacing: 20) {
                    Text("Question \(viewModel.currentIndex + 1) of \(viewModel.questions.count)")
                        .font(.headline)
                        .padding(.top)
                    
                    ProgressView(value: Double(viewModel.currentIndex), total: Double(viewModel.questions.count))
                        .padding(.horizontal)
                        .padding(.bottom)
                    
                    Text("What is the meaning of:")
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
                                
                                // Auto advance after showing correct answer
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                    if showNextButton {
                                        viewModel.answerCurrentQuestion(with: option)
                                        selectedAnswer = nil
                                        showNextButton = false
                                    }
                                }
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
                }
                .padding()
            } else {
                Text("Not enough cards to generate a test.")
            }
        }
        .navigationTitle("Test")
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
