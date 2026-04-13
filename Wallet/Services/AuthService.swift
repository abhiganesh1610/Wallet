//
//  AuthService.swift
//  Wallet
//
//  Created by Ganesh on 10/04/26.
//

import FirebaseAuth
import FirebaseFirestore
import SwiftUI

class AuthService {
    static let shared = AuthService()
    let db = Firestore.firestore()
    
    func register(email: String, password: String, completion: @escaping (Bool) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { res, err in
            guard let user = res?.user else {
                completion(false)
                return
            }
            
            self.db.collection("users").document(user.uid).setData([
                "email": email,
                "balance": 0,
                "qrId": user.uid
            ])
            
            completion(true)
        }
    }
    
    func login(email: String, password: String, completion: @escaping (Bool) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { _, err in
            completion(err == nil)
        }
    }
}





struct ToastView: View {
    
    var message: String
    var isSuccess: Bool
    
    var body: some View {
        HStack {
            Image(systemName: isSuccess ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(.white)
            
            Text(message)
                .foregroundColor(.white)
                .font(.subheadline)
                .bold()
        }
        .padding()
        .background(isSuccess ? Color.green : Color.red)
        .cornerRadius(12)
        .shadow(radius: 5)
        .padding(.horizontal)
    }
}
