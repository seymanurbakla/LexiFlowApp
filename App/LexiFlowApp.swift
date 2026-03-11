import SwiftUI

@main
struct LexiFlowApp: App {
    @StateObject private var store = StudySetStore()
    @AppStorage("appLanguage") private var appLanguage = "en"
    
    var body: some Scene {
        WindowGroup {
            StudySetListView()
                .environmentObject(store)
                .environment(\.locale, .init(identifier: appLanguage))
        }
    }
}
