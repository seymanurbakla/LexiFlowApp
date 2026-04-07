import Foundation

class AIManager {
    static let shared = AIManager()
    
    // IMPORTANT: Replace this with your actual Gemini API Key from Google AI Studio (https://aistudio.google.com/app/apikey)
    // Generating an API key is completely free.
    private let apiKey = ""
    
    func generateExampleSentence(for word: String) async throws -> String {
        guard !apiKey.isEmpty else {
            throw NSError(domain: "AIManager", code: 401, userInfo: [NSLocalizedDescriptionKey: "AI API Key missing. Please add your Gemini API Key in AIManager.swift"])
        }
        
        let prompt = """
        Generate an English example sentence for the word "\(word)".
        Rules:
        1. Use its most common meaning in YDS-style academic contexts.
        2. Keep it short, clear, and suitable for B1-B2 learners.
        3. Avoid rare meanings or heavy idioms.
        4. Below the English sentence, provide the Turkish translation in parentheses.
        Example format: 
        The committee will discuss the new proposal. (Komite yeni teklifi tartışacak.)
        
        Respond ONLY with the formatted text, no extra markdown, quotes, or explanations.
        """
        
        let urlString = "https://generativelanguage.googleapis.com/v1beta/models/gemini-flash-latest:generateContent?key=\(apiKey)"
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let requestBody: [String: Any] = [
            "contents": [
                ["parts": [["text": prompt]]]
            ]
        ]
        
        let data = try JSONSerialization.data(withJSONObject: requestBody)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = data
        
        let (responseData, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
            let errorText = String(data: responseData, encoding: .utf8) ?? "Bilinmeyen API Hatası"
            throw NSError(domain: "AIManager", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Google AI Hatası (\(httpResponse.statusCode)): Lütfen API anahtarınızın doğru ve aktif olduğundan emin olun."])
        }
        
        struct GeminiResponse: Decodable {
            struct Candidate: Decodable {
                struct Content: Decodable {
                    struct Part: Decodable {
                        let text: String
                    }
                    let parts: [Part]
                }
                let content: Content
            }
            let candidates: [Candidate]
        }
        
        let geminiResponse = try JSONDecoder().decode(GeminiResponse.self, from: responseData)
        guard let text = geminiResponse.candidates.first?.content.parts.first?.text else {
            throw NSError(domain: "AIManager", code: 500, userInfo: [NSLocalizedDescriptionKey: "Could not parse AI response."])
        }
        
        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func generateTrickyDistractors(for words: [String: String]) async throws -> [String: [String]] {
        guard !apiKey.isEmpty else {
            throw NSError(domain: "AIManager", code: 401, userInfo: [NSLocalizedDescriptionKey: "AI API Key missing."])
        }
        
        let wordsJson = try! String(data: JSONEncoder().encode(words), encoding: .utf8)!
        
        let prompt = """
        You are an expert English language examiner creating a difficult vocabulary test for Turkish students.
        I will give you a JSON object mapping English words to their correct Turkish meanings.
        For each English word, generate exactly 3 tricky, plausible, but incorrect Turkish meanings (distractors). 
        The distractors should be related to the word's theme, sound, or spelling to confuse the student (çeldirici).
        
        Input:
        \(wordsJson)
        
        Output format: MUST be a strict JSON object where keys are the English words, and values are arrays of exactly 3 strings (the Turkish distractors). No markdown, no quotes outside JSON, just the raw JSON.
        """
        
        let urlString = "https://generativelanguage.googleapis.com/v1beta/models/gemini-flash-latest:generateContent?key=\(apiKey)"
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let requestBody: [String: Any] = [
            "contents": [
                ["parts": [["text": prompt]]]
            ],
            "generationConfig": [
                "response_mime_type": "application/json"
            ]
        ]
        
        let data = try JSONSerialization.data(withJSONObject: requestBody)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = data
        
        let (responseData, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
            throw NSError(domain: "AIManager", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Google AI Hatası (\(httpResponse.statusCode)): Lütfen API anahtarınızın doğru ve aktif olduğundan emin olun."])
        }
        
        struct GeminiResponse: Decodable {
            struct Candidate: Decodable {
                struct Content: Decodable {
                    struct Part: Decodable {
                        let text: String
                    }
                    let parts: [Part]
                }
                let content: Content
            }
            let candidates: [Candidate]
        }
        
        let geminiResponse = try JSONDecoder().decode(GeminiResponse.self, from: responseData)
        guard var jsonText = geminiResponse.candidates.first?.content.parts.first?.text else {
            throw NSError(domain: "AIManager", code: 500, userInfo: [NSLocalizedDescriptionKey: "Could not parse AI response."])
        }
        
        // Strip markdown if AI returned it
        jsonText = jsonText.trimmingCharacters(in: .whitespacesAndNewlines)
        if jsonText.hasPrefix("```json") {
            jsonText = jsonText.replacingOccurrences(of: "```json", with: "")
        } else if jsonText.hasPrefix("```") {
            jsonText = jsonText.replacingOccurrences(of: "```", with: "")
        }
        if jsonText.hasSuffix("```") {
            jsonText = String(jsonText.dropLast(3))
        }
        jsonText = jsonText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard let jsonData = jsonText.data(using: .utf8) else {
            throw NSError(domain: "AIManager", code: 500, userInfo: [NSLocalizedDescriptionKey: "JSON conversion error."])
        }
        
        do {
            let result = try JSONDecoder().decode([String: [String]].self, from: jsonData)
            return result
        } catch {
            print("AI JSON Decode Error: \(error)")
            print("Raw text: \(jsonText)")
            throw error
        }
    }
}
