import Foundation
import FirebaseAuth
import GoogleSignIn
import FirebaseCore
import UIKit

class AuthManager: ObservableObject {
    @Published var currentUser: User?
    
    init() {
        self.currentUser = Auth.auth().currentUser
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.currentUser = user
        }
    }
    
    func signInWithGoogle(presentingViewController: UIViewController) {
        // Will throw an error if Firebase hasn't been configured or GoogleService-Info was missing
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            print("No clientID found in FirebaseApp. Did you forget your GoogleService-Info.plist?")
            return
        }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController) { result, error in
            if let error = error {
                print("Error signing in with Google: \(error.localizedDescription)")
                return
            }
            guard let user = result?.user, let idToken = user.idToken?.tokenString else { return }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    print("Firebase sign in error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            GIDSignIn.sharedInstance.signOut()
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
}

// Helper to easily get the root view controller from anywhere in SwiftUI
extension UIApplication {
    var keyWindow: UIWindow? {
        connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
    }
    
    var rootViewController: UIViewController? {
        keyWindow?.rootViewController
    }
}
