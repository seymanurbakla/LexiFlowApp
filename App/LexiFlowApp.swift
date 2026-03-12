import SwiftUI

@main
struct LexiFlowApp: App {
    @StateObject private var store = StudySetStore()
    @StateObject private var languageManager = AppLanguageManager()
    
    var body: some Scene {
        WindowGroup {
            StudySetListView()
                .environmentObject(store)
                .environmentObject(languageManager)
                .environment(\.locale, .init(identifier: languageManager.language))
                .id(languageManager.uuid) // Forces complete redraw on language change
        }
    }
}
