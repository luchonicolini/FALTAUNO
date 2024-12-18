//
//  Authentication.swift
//  PidoUno
//
//  Created by Luciano Nicolini on 14/12/2024.
//

import FirebaseAuth
import Combine
import GoogleSignIn
import GoogleSignInSwift
import FirebaseCore
// For Sign in with Apple
import AuthenticationServices
import CryptoKit

enum AuthenticationFlow {
    case login
    case signUp
}

enum AuthenticationState {
    case unauthenticated
    case authenticating
    case authenticated
}

@Observable
class AuthenticationViewModel {
    var email: String = ""
    var password: String = ""
    var confirmPassword: String = ""
    var errorMessage: String = ""
    
    private(set) var isValid: Bool = false
    private(set) var authenticationState: AuthenticationState = .unauthenticated
    private(set) var flow: AuthenticationFlow = .login
    private(set) var user: User?
    private(set) var displayName = ""
    
    private var authStateHandler: AuthStateDidChangeListenerHandle?
    private var currentNonce: String?
    
    init() {
        registerAuthStateHandler()
        verifySignInWithAppleAuthenticationState()
        
        Task {
            for await _ in Combine.Empty<Void, Never>().values {
                isValid = flow == .login
                ? !(email.isEmpty || password.isEmpty)
                : !(email.isEmpty || password.isEmpty || confirmPassword.isEmpty)
            }
        }
    }
    
    deinit {
        if let handler = authStateHandler {
            Auth.auth().removeStateDidChangeListener(handler)
        }
    }
    
    func registerAuthStateHandler() {
        authStateHandler = Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            self?.user = user
            self?.authenticationState = user == nil ? .unauthenticated : .authenticated
        }
    }
    
    func switchFlow() {
        flow = flow == .login ? .signUp : .login
        errorMessage = ""
    }
    
    func reset() {
        flow = .login
        email = ""
        password = ""
        confirmPassword = ""
        errorMessage = ""
    }
    
    // MARK: - Login
    
    func login() async -> Bool {
        authenticationState = .authenticating // Estado de carga
        
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            if !result.user.isEmailVerified {
                errorMessage = NSLocalizedString("Please verify your email address before signing in.", comment: "")
                authenticationState = .unauthenticated
                return false
            }
            // Clear input fields on success
            email = ""; password = ""
            authenticationState = .authenticated
            return true
        } catch {
            errorMessage = error.localizedDescription
            authenticationState = .unauthenticated // Reset state on error
            return false
        }
    }
    
    // MARK: - Register
    
    func signUp() async -> Bool {
        print("🔐 Iniciando registro...")
        authenticationState = .authenticating // Estado de carga
        
        guard password == confirmPassword else {
            print("❌ Contraseñas no coinciden")
            errorMessage = NSLocalizedString("Passwords do not match.", comment: "")
            authenticationState = .unauthenticated // Reset state on error
            return false
        }
        
        do {
            print("🚀 Intentando crear usuario con email: \(email)")
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            print("✅ Usuario creado: \(result.user.uid)")
            
            try await sendEmailVerification(for: result.user)
            print("📧 Verificación de email enviada")
            
            // Importante: establecer el estado de autenticación manualmente
            authenticationState = .authenticated
            
            email = ""; password = ""; confirmPassword = ""
            return true
        } catch let error as NSError {
            print("❌ Error en registro: \(error.localizedDescription)")
            print("Código de error: \(error.code)")
            
            authenticationState = .unauthenticated // Reset state on error
            
            switch error.code {
            case AuthErrorCode.emailAlreadyInUse.rawValue:
                errorMessage = "El correo ya está registrado"
            case AuthErrorCode.weakPassword.rawValue:
                errorMessage = "Contraseña muy débil"
            case AuthErrorCode.invalidEmail.rawValue:
                errorMessage = "Email inválido"
            default:
                errorMessage = error.localizedDescription
            }
            return false
        } catch {
            print("❌ Error desconocido: \(error.localizedDescription)")
            authenticationState = .unauthenticated // Reset state on error
            errorMessage = error.localizedDescription
            return false
        }
    }
    
    private func sendEmailVerification(for user: User) async throws {
        try await user.sendEmailVerification()
        print("Verification email sent.")
    }
    
    // MARK: - SignOut
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            user = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - Delete Account
    
    func deleteAccount() async -> Bool {
        do {
            try await user?.delete()
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}


// MARK: - Google Sign-In

enum AuthenticationError: Error {
    case tokenError(message: String)
}

extension AuthenticationViewModel {
    func signInWithGoogle() async -> Bool {
        authenticationState = .authenticating // Estado de carga
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            fatalError("No client ID found in Firebase configuration")
        }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        guard let windowScene = await UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = await windowScene.windows.first,
              let rootViewController = await window.rootViewController else {
            print("There is no root view controller!")
            authenticationState = .unauthenticated // Reset state on error
            return false
        }
        
        do {
            let userAuthentication = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
            
            let user = userAuthentication.user
            guard let idToken = user.idToken else {
                authenticationState = .unauthenticated // Reset state on error
                throw AuthenticationError.tokenError(message: "ID token missing")
            }
            let accessToken = user.accessToken
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken.tokenString,
                                                           accessToken: accessToken.tokenString)
            
            let result = try await Auth.auth().signIn(with: credential)
            let firebaseUser = result.user
            print("User \(firebaseUser.uid) signed in with email \(firebaseUser.email ?? "unknown")")
            authenticationState = .authenticated
            return true
        } catch {
            print(error.localizedDescription)
            self.errorMessage = error.localizedDescription
            authenticationState = .unauthenticated // Reset state on error
            return false
        }
    }
}


// MARK: Sign in with Apple

extension AuthenticationViewModel {
    
    func handleSignInWithAppleRequest(_ request: ASAuthorizationAppleIDRequest) {
        authenticationState = .authenticating // Estado de carga
        request.requestedScopes = [.fullName, .email]
        let nonce = randomNonceString()
        currentNonce = nonce
        request.nonce = sha256(nonce)
    }
    
    func handleSignInWithAppleCompletion(_ result: Result<ASAuthorization, Error>) async -> Bool {
        switch result {
        case .failure(let failure):
            errorMessage = failure.localizedDescription
            authenticationState = .unauthenticated // Reset state on error
            return false
        case .success(let authorization):
            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                guard let nonce = currentNonce else {
                    errorMessage = "Invalid authentication state"
                    authenticationState = .unauthenticated // Reset state on error
                    return false
                }
                
                guard let appleIDToken = appleIDCredential.identityToken else {
                    errorMessage = "Unable to fetch identity token"
                    authenticationState = .unauthenticated // Reset state on error
                    return false
                }
                
                guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                    errorMessage = "Unable to serialize token string"
                    authenticationState = .unauthenticated // Reset state on error
                    return false
                }
                
                do {
                    let credential = OAuthProvider.appleCredential(withIDToken: idTokenString,
                                                                   rawNonce: nonce,
                                                                   fullName: appleIDCredential.fullName)
                    
                    let result = try await Auth.auth().signIn(with: credential)
                    await updateDisplayName(for: result.user, with: appleIDCredential)
                    
                    // Limpiar campos de entrada
                    email = ""
                    
                    authenticationState = .authenticated
                    return true
                } catch {
                    errorMessage = error.localizedDescription
                    authenticationState = .unauthenticated // Reset state on error
                    return false
                }
            }
            return false
        }
    }
    
    // Actualiza el nombre de visualización del usuario en Firebase con la información proporcionada por Apple.
    func updateDisplayName(for user: User, with appleIDCredential: ASAuthorizationAppleIDCredential, force: Bool = false) async {
        if let currentDisplayName = Auth.auth().currentUser?.displayName, !currentDisplayName.isEmpty {
            // current user is non-empty, don't overwrite it
        }
        else {
            let changeRequest = user.createProfileChangeRequest()
            changeRequest.displayName = appleIDCredential.displayName()
            do {
                try await changeRequest.commitChanges()
                self.displayName = Auth.auth().currentUser?.displayName ?? ""
            }
            catch {
                print("Unable to update the user's displayname: \(error.localizedDescription)")
                errorMessage = error.localizedDescription
            }
        }
    }
    
    func verifySignInWithAppleAuthenticationState() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let providerData = Auth.auth().currentUser?.providerData
        if let appleProviderData = providerData?.first(where: { $0.providerID == "apple.com" }) {
            Task {
                do {
                    let credentialState = try await appleIDProvider.credentialState(forUserID: appleProviderData.uid)
                    switch credentialState {
                    case .authorized:
                        break // The Apple ID credential is valid.
                    case .revoked, .notFound:
                        // The Apple ID credential is either revoked or was not found, so show the sign-in UI.
                        self.signOut()
                    default:
                        break
                    }
                }
                catch {
                }
            }
        }
    }
    
}

extension ASAuthorizationAppleIDCredential {
    func displayName() -> String {
        return [self.fullName?.givenName, self.fullName?.familyName]
            .compactMap( {$0})
            .joined(separator: " ")
    }
}

// Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
private func randomNonceString(length: Int = 32) -> String {
    precondition(length > 0)
    let charset: [Character] =
    Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
    var result = ""
    var remainingLength = length
    
    while remainingLength > 0 {
        let randoms: [UInt8] = (0 ..< 16).map { _ in
            var random: UInt8 = 0
            let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
            if errorCode != errSecSuccess {
                fatalError(
                    "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
                )
            }
            return random
        }
        
        randoms.forEach { random in
            if remainingLength == 0 {
                return
            }
            
            if random < charset.count {
                result.append(charset[Int(random)])
                remainingLength -= 1
            }
        }
    }
    
    return result
}

private func sha256(_ input: String) -> String {
    let inputData = Data(input.utf8)
    let hashedData = SHA256.hash(data: inputData)
    let hashString = hashedData.compactMap {
        String(format: "%02x", $0)
    }.joined()
    
    return hashString
}
