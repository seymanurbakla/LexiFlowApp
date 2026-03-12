import SwiftUI

struct FlashcardSessionView: View {
    @EnvironmentObject var store: StudySetStore
    @StateObject private var viewModel: FlashcardSessionViewModel
    @State private var offset: CGSize = .zero
    @State private var flipped: Bool = false
    
    init(studySet: StudySet, store: StudySetStore, isShuffled: Bool) {
        _viewModel = StateObject(wrappedValue: FlashcardSessionViewModel(studySet: studySet, store: store, isShuffled: isShuffled))
    }
    
    var body: some View {
        VStack {
            if viewModel.isFinished {
                VStack(spacing: 20) {
                    Image(systemName: "party.popper.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    Text(NSLocalizedString("You've studied all cards in this set!", comment: ""))
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Button(NSLocalizedString("Reset Flashcards", comment: "")) {
                        withAnimation {
                            viewModel.resetProgress()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            } else {
                // Progress Counter
                HStack {
                    Spacer()
                    Text("\(viewModel.currentIndex + 1) / \(viewModel.cardsToReview.count)")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                }
                
                ZStack {
                    if let card = viewModel.currentCard {
                        FlashcardCardView(card: card, flipped: $flipped)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .fill(offset.width > 0 ? Color.green : Color.red)
                                    .opacity(min(Double(abs(offset.width) / 300.0), 0.5))
                            )
                            .zIndex(1)
                            .offset(x: offset.width, y: offset.height)
                            .rotationEffect(.degrees(Double(offset.width / 10)))
                            .gesture(
                                DragGesture()
                                    .onChanged { gesture in
                                        offset = gesture.translation
                                    }
                                    .onEnded { gesture in
                                        handleSwipe(for: card, translation: gesture.translation)
                                    }
                            )
                            .animation(.spring(), value: offset)
                    }
                }
                .padding()
                
                HStack(spacing: 40) {
                    Button(action: {
                        if let card = viewModel.currentCard {
                            withAnimation {
                                offset = CGSize(width: -500, height: 0)
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                viewModel.swipeLeft(on: card)
                                offset = .zero
                                flipped = false
                            }
                        }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.red)
                    }
                    
                    Button(action: {
                        if let card = viewModel.currentCard {
                            withAnimation {
                                offset = CGSize(width: 500, height: 0)
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                viewModel.swipeRight(on: card)
                                offset = .zero
                                flipped = false
                            }
                        }
                    }) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.green)
                    }
                }
                .padding(.top, 20)
            }
        }
        .navigationTitle(NSLocalizedString("Flashcards", comment: ""))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(NSLocalizedString("Reset", comment: "")) {
                    withAnimation {
                        viewModel.resetProgress()
                    }
                }
            }
        }
    }
    
    private func handleSwipe(for card: Flashcard, translation: CGSize) {
        let swipeThreshold: CGFloat = 100
        
        if translation.width > swipeThreshold {
            // Swiped right - "Known"
            withAnimation {
                offset = CGSize(width: 500, height: 0)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                viewModel.swipeRight(on: card)
                offset = .zero
                flipped = false
            }
        } else if translation.width < -swipeThreshold {
            // Swiped left - "Don't know"
            withAnimation {
                offset = CGSize(width: -500, height: 0)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                viewModel.swipeLeft(on: card)
                offset = .zero
                flipped = false
            }
        } else {
            // Return to center
            withAnimation(.spring()) {
                offset = .zero
            }
        }
    }
}

// Subview for the individual card
struct FlashcardCardView: View {
    let card: Flashcard
    @Binding var flipped: Bool
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(UIColor.secondarySystemBackground))
                .shadow(radius: 5)
            
            VStack {
                Spacer()
                if !flipped {
                    Text(card.word)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .padding()
                } else {
                    Text(card.meaning)
                        .font(.title)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    if !card.exampleSentence.isEmpty {
                        Divider()
                            .padding(.horizontal)
                        
                        Text(card.exampleSentence)
                            .font(.body)
                            .italic()
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                }
                Spacer()
            }
            .rotation3DEffect(
                .degrees(flipped ? 180 : 0),
                axis: (x: 0.0, y: 1.0, z: 0.0)
            )
        }
        .frame(height: 400)
        .rotation3DEffect(
            .degrees(flipped ? 180 : 0),
            axis: (x: 0.0, y: 1.0, z: 0.0)
        )
        .onTapGesture {
            withAnimation(.spring()) {
                flipped.toggle()
            }
        }
    }
}
