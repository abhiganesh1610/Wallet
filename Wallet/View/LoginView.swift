//
//  LoginView.swift
//  Wallet
//
//  Created by Ganesh on 10/04/26.
//

import SwiftUI

struct LoginView: View {
    
    @State var email = ""
    @State var password = ""
    @State var isLogin = true
    @State var loggedIn = false
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isLoading = false
    @State private var showPassword = false
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.blue, .purple],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 10) {
                
                Rectangle()
                    .frame(height: 150)
                    .opacity(0)
                
                Text("Wallet App")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(isLogin ? "Login to continue" : "Create new account")
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.bottom,8)
                
                VStack(spacing: 15) {
                    
                    TextField("Email", text: $email)
                        .padding()
                        .frame(height: 50)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                        .keyboardType(.emailAddress)
                    
                    HStack {
                        if showPassword {
                            TextField("Password", text: $password)
                        } else {
                            SecureField("Password", text: $password)
                        }
                        
                        Button(action: {
                            showPassword.toggle()
                        }) {
                            Image(systemName: !showPassword ? "eye.slash" : "eye")
                                .padding(.trailing, 5)
                                .foregroundColor(.black)
                        }
                    }
                    .padding()
                    .frame(height: 50)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.bottom,5)
                    
                    Button(action: handleAuth) {
                        if isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .padding()
                        } else {
                            Text(isLogin ? "Login" : "Register")
                                .frame(maxWidth: .infinity)
                                .padding()
                        }
                    }
                    .frame(height: 45)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    
                    Button(action: {
                        email = ""
                        password = ""
                        showPassword = false
                        isLogin.toggle()
                    }) {
                        Text(isLogin ? "Don't have an account? Register"
                             : "Already have an account? Login")
                        .font(.footnote)
                    }
                    .padding(.vertical, 5)
                    
                }
                .padding()
                .background(Color.white)
                .cornerRadius(20)
                .padding(.horizontal)
                
                Spacer()
            }
            
            NavigationLink("", destination: WalletView(), isActive: $loggedIn)
        }
        .alert("Error", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
    }
    
    func handleAuth() {
        
        guard !email.isEmpty, !password.isEmpty else {
            showError("Email and Password cannot be empty")
            return
        }
        
        guard email.contains("@") else {
            showError("Enter valid email")
            return
        }
        
        guard password.count >= 6 else {
            showError("Password must be at least 6 characters")
            return
        }
        
        isLoading = true
        
        if isLogin {
            AuthService.shared.login(email: email, password: password) { success in
                DispatchQueue.main.async {
                    isLoading = false
                    if success {
                        UserDefaultsHelper.shared.set(true, forKey: UserDefaultsKeys.isLoggedIn)
                        loggedIn = true
                    } else {
                        showError("Login failed. Check credentials.")
                    }
                }
            }
        } else {
            AuthService.shared.register(email: email, password: password) { success in
                DispatchQueue.main.async {
                    isLoading = false
                    if success {
                        UserDefaultsHelper.shared.set(true, forKey: UserDefaultsKeys.isLoggedIn)
                        loggedIn = true
                    } else {
                        showError("Registration failed. Try again.")
                    }
                }
            }
        }
    }
    
    func showError(_ message: String) {
        alertMessage = message
        showAlert = true
    }
}
