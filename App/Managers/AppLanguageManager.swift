import SwiftUI

class AppLanguageManager: ObservableObject {
    @AppStorage("appLanguage") private var storedLanguage: String = "tr" {
        didSet {
            language = storedLanguage
            uuid = UUID() // Force redraw
        }
    }
    
    @Published var language: String = "tr"
    @Published var uuid = UUID()
    
    init() {
        self.language = storedLanguage
    }
    
    func setLanguage(_ lang: String) {
        storedLanguage = lang
    }
}
