//
//  WalletApp.swift
//  Wallet
//
//  Created by Ganesh on 10/04/26.
//

import SwiftUI
import FirebaseAuth

@main
struct WalletApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        WindowGroup {
            NavigationView{
                Walletview()
            }.navigationViewStyle(.stack)
        }
    }
}


struct Walletview: View {
    @State private var user: User? = Auth.auth().currentUser
    @State private var authListenerHandle: AuthStateDidChangeListenerHandle?
    var body: some View {
        NavigationStack {
            Group {
                //                if UserDefaultsHelper.shared.getBool(forKey: UserDefaultsKeys.isLoggedIn) {
                if user != nil {
                    WalletView()
                } else {
                    LoginView()
                }
            }
        }
        .onAppear {
            authListenerHandle = Auth.auth().addStateDidChangeListener { _, newUser in
                user = newUser
            }
        }
        .onDisappear {
            if let handle = authListenerHandle {
                Auth.auth().removeStateDidChangeListener(handle)
                authListenerHandle = nil
            }
        }
    }
}
