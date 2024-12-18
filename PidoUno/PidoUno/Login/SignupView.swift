//
//  SignupView.swift
//  PidoUno
//
//  Created by Luciano Nicolini on 16/12/2024.
//

import Combine
import SwiftUI

private enum FocusableField: Hashable {
    case email
    case password
    case confirmPassword
}

struct SignupView: View {
    @State var viewModel = AuthenticationViewModel()
    @Environment(\.dismiss) var dismiss
    @State private var registrationSuccessful = false
    @FocusState private var focus: FocusableField?
    
    private func signUpWithEmailPassword() {
        Task {
            let success = await viewModel.signUp()
            if success {
                registrationSuccessful = true
                dismiss()
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("Color").edgesIgnoringSafeArea(.all)
                ScrollView(showsIndicators: false) {
                    VStack {
                        Text("Registro")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        //Email
                        HStack {
                            Image(systemName: "at")
                            TextField("Email", text: $viewModel.email)
                                .textInputAutocapitalization(.never)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .focused($focus, equals: .email)
                                .submitLabel(.next)
                                .onSubmit {
                                    self.focus = .password
                                }
                        }
                        .padding(.vertical, 6)
                        .background(Divider(), alignment: .bottom)
                        .padding(.bottom, 4)
                        
                        //Password
                        HStack {
                            Image(systemName: "lock")
                            SecureField("Password", text: $viewModel.password)
                                .focused($focus, equals: .password)
                                .submitLabel(.next)
                                .onSubmit {
                                    self.focus = .confirmPassword
                                }
                            
                            
                        }
                        .padding(.vertical, 6)
                        .background(Divider(), alignment: .bottom)
                        .padding(.bottom, 8)
                        
                        //Confirm Password
                        HStack {
                            Image(systemName: "lock")
                            SecureField("Confirm password", text: $viewModel.confirmPassword)
                                .focused($focus, equals: .confirmPassword)
                                .submitLabel(.go)
                                .onSubmit {
                                    signUpWithEmailPassword()
                                }
                            
                            
                        }
                        .padding(.vertical, 6)
                        .background(Divider(), alignment: .bottom)
                        .padding(.bottom, 8)
                        
                        //errorMessage
                        
                        if !viewModel.errorMessage.isEmpty {
                            Text(viewModel.errorMessage)
                                .font(.caption)
                                .foregroundColor(.red)
                                .transition(.asymmetric(insertion: .move(edge: .bottom).combined(with: .opacity),
                                                        removal: .move(edge: .top).combined(with: .opacity)))
                                .animation(.easeInOut(duration: 0.3), value: viewModel.errorMessage)
                        }
                        
                        //ButtonView
                        Button(action: signUpWithEmailPassword) {
                            Text("Crear Cuenta")
                                .font(.system(size: 17, weight: .semibold))
                                .padding(.vertical, 8)
                                .fontWeight(.medium)
                                .frame(maxWidth: .infinity)
                                .opacity(viewModel.authenticationState == .authenticating ? 0.5 : 1.0)
                                .scaleEffect(viewModel.authenticationState == .authenticating ? 0.95 : 1.0)
                        }
                        .frame(maxWidth: .infinity)
                        .buttonStyle(.bordered)
                        .foregroundStyle(.primary)
                        .disabled(viewModel.authenticationState == .authenticating)
                        .animation(.spring(), value: viewModel.authenticationState)
                        
                        Divider()
                        
                        Button(action: {
                            dismiss()
                        }, label: {
                            HStack(spacing: 6) {
                                Text("Ya tiene una cuenta?")
                                Text("Acceder")
                                    .fontWeight(.semibold)
                                    .foregroundColor(.blue)
                            }
                            .foregroundColor(.primary)
                        })
                        .padding([.top, .bottom], 10)
                        
                    }
                    .alert(isPresented: $registrationSuccessful) {
                        Alert(title: Text("Registro Exitoso"),
                              message: Text("Se ha enviado un correo electrónico para verificar su cuenta."),
                              dismissButton: .default(Text("Ok"), action: {
                            dismiss()
                        }))
                    }
                }
                .listStyle(.plain)
                .padding()
            }
        }
    }
}

#Preview {
    SignupView(viewModel: AuthenticationViewModel())
}
