import SwiftUI
import GoogleSignIn

struct LoginView: View {
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        VStack {
            Spacer()
            
            Image(systemName: "books.vertical.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.blue)
                .padding(.bottom, 20)
            
            Text("LexiFlow")
                .font(.system(size: 40, weight: .bold, design: .rounded))
            
            Text("Learn vocabulary and sync across all your devices.")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .padding(.bottom, 50)
            
            Button(action: {
                if let rootVC = UIApplication.shared.rootViewController {
                    authManager.signInWithGoogle(presentingViewController: rootVC)
                }
            }) {
                HStack {
                    Image(systemName: "g.circle.fill")
                        .font(.title2)
                    Text("Sign in with Google")
                        .fontWeight(.semibold)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
                .padding(.horizontal, 40)
            }
            
            Spacer()
        }
    }
}
