import SwiftUI
import FirebaseCore
import GoogleSignIn

@main
struct LexiFlowApp: App {
    @StateObject private var authManager = AuthManager()
    @StateObject private var store = StudySetStore()
    @AppStorage("appLanguage") private var appLanguage = "en"
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            if authManager.currentUser != nil {
                StudySetListView()
                    .environmentObject(store)
                    .environmentObject(authManager)
                    .environment(\.locale, .init(identifier: appLanguage))
            } else {
                LoginView()
                    .environmentObject(authManager)
                    .environment(\.locale, .init(identifier: appLanguage))
            }
        }
    }
}
