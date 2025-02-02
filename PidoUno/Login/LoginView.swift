//
//  LoginView.swift
//  PidoUno
//
//  Created by Luciano Nicolini on 14/12/2024.
//

import SwiftUI
import AuthenticationServices

private enum FocusableField: Hashable {
    case email
    case password
}

struct LoginView: View {
    @State var authViewModel: AuthenticationViewModel
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @State private var showDetails = false
    @FocusState private var focus: FocusableField?
    @State var showPassword = false
    @State private var isLoading = false

    
    
    private func signInWithEmail() {
        isLoading = true
        Task {
            let success = await authViewModel.login()
            isLoading = false
            if success {
                dismiss()
                showDetails = true
            }
        }
    }
    
    private func signInWithGoogle() {
        isLoading = true
        Task {
            let success = await authViewModel.signInWithGoogle()
            isLoading = false
            if success {
                dismiss()
                showDetails = true
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("Color").edgesIgnoringSafeArea(.all)
                ScrollView(showsIndicators: false) {
                    VStack {
                        
                        Text("Iniciar Sesion")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text("Es tu primera vez?")
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        
                        // Email
                        HStack {
                            Image(systemName: "at")
                            TextField("Email", text: $authViewModel.email)
                                .textInputAutocapitalization(.never)
                                .keyboardType(.emailAddress)
                                .disableAutocorrection(true)
                                .focused($focus, equals: .email)
                                .submitLabel(.next)
                                .onSubmit { self.focus = .password }
                        }
                        .padding(.vertical, 6)
                        .background(Divider(), alignment: .bottom)
                        .padding(.bottom, 4)
                        
                        
                        
                        // Password
                        HStack {
                            Image(systemName: "lock")
                            
                            if showPassword {
                                TextField("Password", text: $authViewModel.password)
                                    .focused($focus, equals: .password)
                                    .submitLabel(.go)
                                    .onSubmit {
                                        Task {
                                            await authViewModel.login()
                                        }
                                    }
                            } else {
                                SecureField("Password", text: $authViewModel.password)
                                    .focused($focus, equals: .password)
                                    .submitLabel(.go)
                                    .onSubmit {
                                        Task {
                                            await authViewModel.login()
                                        }
                                    }
                            }
                            
                            Image(systemName: showPassword ? "eye.fill" : "eye.slash.fill")
                                .padding(16)
                                .contentShape(Rectangle())
                                .foregroundStyle(showPassword ? .primary : .secondary)
                                .onTapGesture {
                                    withAnimation(.bouncy) {
                                        showPassword.toggle()
                                    }
                                }
                                .scaleEffect(showPassword ? 1.0 : 0.9)
                                .animation(.spring(), value: showPassword)
                        }
                        .background(Divider(), alignment: .bottom)
                        .padding(.bottom, 8)
                        
                        
                        // Sign In Button
                        //signInWithEmail
                        Button(action: signInWithEmail) {
                            Text("Iniciar Sesion")
                                .font(.system(size: 18))
                                .padding(.vertical, 8)
                                .foregroundStyle(Color.primary)
                                .frame(maxWidth: .infinity)
                                .opacity(isLoading ? 0.5 : 1.0)
                                .scaleEffect(isLoading ? 0.95 : 1.0)
                        }
                        .disabled(isLoading)
                        .animation(.spring(), value: isLoading)
                        .frame(maxWidth: .infinity)
                        .buttonStyle(.bordered)
                        
                   
                        
                        // Error Message
                        if !authViewModel.errorMessage.isEmpty {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundStyle(.red)
                                    .font(.caption)
                                
                                Text(authViewModel.errorMessage)
                                    .font(.caption)
                                    .foregroundColor(Color(UIColor.systemRed))
                                    .transition(.asymmetric(insertion: .move(edge: .bottom).combined(with: .opacity),
                                                            removal: .move(edge: .top).combined(with: .opacity)))
                                    .animation(.easeInOut(duration: 0.3), value: authViewModel.errorMessage)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.bottom, 8)
                        }
                        
                      
                        
                        HStack {
                            VStack { Divider() }
                            Text("or")
                            VStack { Divider() }
                        }
                        
                        //signInWithGoogle
                        Button(action: signInWithGoogle) {
                            Text("Iniciar sesion con Google")
                                .font(.system(size: 18, weight: .medium, design: .rounded))
                                .padding(.vertical, 8)
                                .frame(maxWidth: .infinity)
                                .background(alignment: .leading) {
                                    Image("Google")
                                        .frame(width: 30, alignment: .center)
                                }
                            
                        }
                        .foregroundStyle(.primary)
                        .buttonStyle(.bordered)
                        
                        
                        //signInWithApple
                        SignInWithAppleButton(.signIn) { request in
                            authViewModel.handleSignInWithAppleRequest(request)
                        } onCompletion: { result in
                            Task {
                                let success = await authViewModel.handleSignInWithAppleCompletion(result)
                                if success {
                                    dismiss()
                                    showDetails = true
                                }
                            }
                        }
                        .signInWithAppleButtonStyle(colorScheme == .light ? .black : .white)
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .cornerRadius(8)
                        
                        
                        //Has olvidado tu contraseña?
                        NavigationLink {
                            ForgotPasswordView(viewModel: authViewModel)
                                .navigationBarBackButtonHidden(true)
                                .transition(.asymmetric(
                                    insertion: .move(edge: .trailing).combined(with: .opacity),
                                    removal: .move(edge: .leading).combined(with: .opacity)
                                ))
                                .animation(.easeInOut(duration: 0.3), value: true)
                        } label: {
                            Text("¿Has olvidado tu contraseña?")
                                .font(.system(size: 16))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .tint(Color.primary)
                        }
                        .padding(.vertical,1)

                        NavigationLink {
                            SignupView()
                                .navigationBarBackButtonHidden(true)
                                .transition(.asymmetric(
                                    insertion: .move(edge: .trailing).combined(with: .opacity),
                                    removal: .move(edge: .leading).combined(with: .opacity)
                                ))
                                .animation(.easeInOut(duration: 0.3), value: true)
                        } label: {
                            HStack(spacing: 6) {
                                Text("¿Aun no tienes cuenta?")
                                    .font(.system(size: 16))
                                Text("Registrate")
                                    .font(.system(size: 16, weight: .medium))
                                    .tint(Color.primary)
                                  
                            }
                            .tint(Color(.gris))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.bottom, 10)
                        
                        .onAppear {
                            authViewModel.reset()
                        }
                    }
                    .listStyle(.plain)
                    .padding()
                    .navigationDestination(isPresented: $showDetails) {
                        HomeView()
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity)
                            ))
                            .animation(.easeInOut(duration: 0.3), value: showDetails)
                    }
                }
            }
        }
    }
}


#Preview {
    LoginView(authViewModel: AuthenticationViewModel())
    
}


