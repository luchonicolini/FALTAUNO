//
//  ForgotPasswordView.swift
//  PidoUno
//
//  Created by Luciano Nicolini on 16/12/2024.
//

import SwiftUI
import FirebaseAuth

struct ForgotPasswordView: View {
    @State var viewModel: AuthenticationViewModel
    @Environment(\.dismiss) var dismiss
    @State private var email = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isResettingPassword = false
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    
    // Función para validar el correo electrónico
    private func isValid(email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    // Función para enviar el correo de recuperación de contraseña
    private func sendPasswordResetEmail() {
        isResettingPassword = true
        
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            self.isResettingPassword = false
            
            if let error = error {
                self.alertMessage = error.localizedDescription
            } else {
                self.alertMessage = "Se ha enviado un correo electrónico para restablecer la contraseña"
            }
            self.showAlert = true
        }
    }
    
    func resetPassword() {
        if isValid(email: email) {
            sendPasswordResetEmail()
        } else {
            self.alertMessage = "Por favor, introduce un correo electrónico válido."
            self.showAlert = true
        }
    }
    
    var body: some View {
        NavigationStack  {
            ZStack {
                Color("Color").edgesIgnoringSafeArea(.all)
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        
                        Text("Recuperar contraseña")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                           
                        
                        Text("Introduzca su dirección de correo electrónico y le enviaremos un enlace para restablecer su contraseña.")
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        HStack {
                            Image(systemName: "at")
                            TextField("Email", text: $email)
                                .textInputAutocapitalization(.never)
                                .disableAutocorrection(true)
                            
                        }
                        .padding(.vertical, 6)
                        .background(Divider(), alignment: .bottom)
                        .padding(.bottom, 4)
                        
                        if !alertMessage.isEmpty && !isResettingPassword {
                                Text(alertMessage)
                                    .font(.caption)
                                    .foregroundColor(.red)
                                    .transition(.asymmetric(insertion: .move(edge: .bottom).combined(with: .opacity),
                                                            removal: .move(edge: .top).combined(with: .opacity)))
                                    .animation(.easeInOut(duration: 0.3), value: alertMessage)
                        }
                        
                        if isResettingPassword {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .padding(.vertical, 8)
                                .frame(maxWidth: .infinity)
                        }
                        
                        Button(action: resetPassword) {
                            Text("Enviar")
                                .font(.system(size: 18))
                                .padding(.vertical, 8)
                                .foregroundStyle(Color.primary)
                                .frame(maxWidth: .infinity)
                                .opacity(isResettingPassword ? 0.5 : 1.0)
                                .scaleEffect(isResettingPassword ? 0.95 : 1.0)
                        }
                        .frame(maxWidth: .infinity)
                        .buttonStyle(.bordered)
                        .animation(.spring(), value: isResettingPassword)
                        .disabled(isResettingPassword)
                        
                        Button(action: {
                            dismiss()
                            
                        }, label: {
                            HStack {
                                Text("Recordo su contraseña?")
                                    .font(.system(size: 16))
                                    .foregroundStyle(Color(.gris))
                                Text("Iniciar sesion")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundStyle(Color.primary)
                                    
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            
                        })
                        Spacer()
                    }
                    
                    .padding(.horizontal)
                    .alert(isPresented: $showAlert) {
                        Alert(title: Text(alertMessage), message: nil, dismissButton: .default(Text("Ok"), action: {
                            if alertMessage == "Se ha enviado un correo electrónico para restablecer la contraseña" {
                                presentationMode.wrappedValue.dismiss()
                            }
                        }))
                    }
                }
            }
        }
    }
}



#Preview {
    ForgotPasswordView(viewModel: AuthenticationViewModel())
}
