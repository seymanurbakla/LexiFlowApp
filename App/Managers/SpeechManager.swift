import AVFoundation

class SpeechManager: ObservableObject {
    static let shared = SpeechManager()
    
    // AVSpeechSynthesizer manages the text-to-speech functionality
    private let synthesizer = AVSpeechSynthesizer()
    
    private init() {
        // App is likely on silent/vibrate, so we must set category to playback for speech to work
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .spokenAudio, options: .duckOthers)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Audio session setup failed: \(error)")
        }
    }
    
    /// Speaks the given text in English.
    func speak(_ text: String, language: String = "en-US") {
        // If it's already speaking, stop before starting a new one
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: language)
        
        // Typical adjustments for better comprehension for learners
        utterance.rate = 0.45 // Slightly slower than default for clarity
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0
        
        synthesizer.speak(utterance)
    }
    
    /// Stops any ongoing speech.
    func stopSpeaking() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
    }
}
