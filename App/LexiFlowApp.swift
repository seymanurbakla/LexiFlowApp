import SwiftUI

@main
struct LexiFlowApp: App {
    @StateObject private var store = StudySetStore()
    
    var body: some Scene {
        WindowGroup {
            StudySetListView()
                .environmentObject(store)
                .environment(\.locale, .init(identifier: "en"))
        }
    }
}
