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
                    Text("You've studied all cards in this set!")
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Button("Reset Flashcards") {
                        withAnimation {
                            viewModel.resetProgress()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            } else {
                // Progress Counter Centered
                Text("\(viewModel.currentIndex + 1) / \(viewModel.totalCardsInRound)")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .padding(.top, 8)
                
                ZStack {
                    if let card = viewModel.currentCard {
                        FlashcardCardView(card: card, flipped: $flipped)
                            .overlay(
                                ZStack {
                                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                                        .fill(offset.width > 0 ? Color.green : Color.red)
                                        .opacity(min(Double(abs(offset.width) / 300.0), 0.4))
                                    
                                    if offset.width > 40 {
                                        VStack {
                                            Text("I KNOW")
                                                .font(.system(size: 36, weight: .heavy, design: .rounded))
                                                .foregroundColor(.green)
                                                .padding(12)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .stroke(Color.green, lineWidth: 4)
                                                )
                                                .rotationEffect(.degrees(-15))
                                            Spacer()
                                        }
                                        .padding(.top, 40)
                                        .opacity(min(Double(abs(offset.width) / 100.0), 1.0))
                                    } else if offset.width < -40 {
                                        VStack {
                                            Text("DON'T KNOW")
                                                .font(.system(size: 36, weight: .heavy, design: .rounded))
                                                .foregroundColor(.red)
                                                .padding(12)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .stroke(Color.red, lineWidth: 4)
                                                )
                                                .rotationEffect(.degrees(15))
                                            Spacer()
                                        }
                                        .padding(.top, 40)
                                        .opacity(min(Double(abs(offset.width) / 100.0), 1.0))
                                    }
                                }
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
                
                HStack {
                    // Left counter (Don't Know)
                    VStack {
                        Text("\(viewModel.sessionUnknownCount)")
                            .font(.title2.bold())
                            .foregroundColor(.red)
                        Text("Don't Know")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(width: 80)
                    
                    Spacer()
                    
                    HStack(spacing: 30) {
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
                    
                    Spacer()
                    
                    // Right Counter (I Know)
                    VStack {
                        Text("\(viewModel.sessionKnownCount)")
                            .font(.title2.bold())
                            .foregroundColor(.green)
                        Text("I Know")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(width: 80)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 15)
            }
        }
        .navigationTitle("Flashcards")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Reset") {
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
                    VStack(spacing: 12) {
                        Text(card.word)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Image(systemName: "speaker.wave.2.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                            .padding(10)
                            .background(Color.blue.opacity(0.1))
                            .clipShape(Circle())
                            .onTapGesture {
                                SpeechManager.shared.speak(card.word)
                            }
                    }
                } else {
                    VStack {
                        Text(card.meaning)
                            .font(.title)
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        if !card.exampleSentence.isEmpty {
                            Divider()
                                .padding(.vertical, 8)
                                .padding(.horizontal)
                            
                            VStack(spacing: 12) {
                                Text(card.exampleSentence)
                                    .font(.body)
                                    .italic()
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                                
                                let englishPart = card.exampleSentence.components(separatedBy: " (").first ?? card.exampleSentence
                                
                                Image(systemName: "speaker.wave.2.fill")
                                    .font(.title3)
                                    .foregroundColor(.blue)
                                    .padding(8)
                                    .background(Color.blue.opacity(0.1))
                                    .clipShape(Circle())
                                    .onTapGesture {
                                        SpeechManager.shared.speak(englishPart)
                                    }
                            }
                        }
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
