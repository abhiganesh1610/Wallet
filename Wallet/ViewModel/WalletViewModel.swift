//
//  WalletViewModel.swift
//  Wallet
//
//  Created by Ganesh on 10/04/26.
//


import Foundation
import FirebaseFirestore
import FirebaseAuth
import Combine


class WalletViewModel: ObservableObject {

    @Published var balance: Double = 0
    @Published var walletItems: [WalletItem] = []
    @Published var transactions: [TransactionModel] = []
    @Published var cards: [CardModel] = []
    @Published var income: Double = 0
    @Published var spent: Double = 0
    @Published var error: String = ""
    @Published var showToast: Bool = false
    @Published var toastMessage: String = ""
    @Published var isSuccess: Bool = false
    @Published var isProcessing = false

    private let db = Firestore.firestore()


    let methods = ["Money Cash", "Debit Card", "Bank Account", "Credit Card"]


    private func userRef() -> DocumentReference? {
        guard let uid = Auth.auth().currentUser?.uid else { return nil }
        return db.collection("users").document(uid)
    }

    func fetchWallet() {
        guard let userRef = userRef() else { return }

        userRef.addSnapshotListener { snapshot, err in

            if let err = err {
                DispatchQueue.main.async {
                    self.error = err.localizedDescription
                }
                return
            }

            guard let data = snapshot?.data() else {
                self.createDefaultWallet()
                return
            }

            DispatchQueue.main.async {

                let wallets = data["wallets"] as? [String: Double] ?? [:]
                let total = wallets.values.reduce(0, +)
                self.balance = total

                self.walletItems = self.methods.map {
                    WalletItem(method: $0, amount: wallets[$0] ?? 0)
                }
            }
        }
    }

    func createDefaultWallet() {
        guard let userRef = userRef() else { return }

        var wallets: [String: Double] = [:]
        methods.forEach { wallets[$0] = 0 }

        userRef.setData([
            "wallets": wallets,
            "balance": 0
        ])
    }

    func addMoney(method: String, amount: Double,desc : String) {

        guard let userRef = userRef() else { return }

        db.runTransaction({ transaction, errorPointer in

            do {
                let doc = try transaction.getDocument(userRef)

                var wallets = doc.data()?["wallets"] as? [String: Double] ?? [:]

                // Ensure all wallets exist
                self.methods.forEach {
                    if wallets[$0] == nil { wallets[$0] = 0 }
                }

                wallets[method]! += amount

                let total = wallets.values.reduce(0, +)

                transaction.updateData([
                    "wallets": wallets,
                    "balance": total
                ], forDocument: userRef)

            } catch {
                errorPointer?.pointee = error as NSError
                return nil
            }

            return nil

        }) { _, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.error = error.localizedDescription
                } else {
                    self.saveTransaction(
                        type: "credit",
                        method: method,
                        amount: amount,
                        description: desc
                    )
                }
            }
        }
    }

    func saveTransaction(type: String, method: String, amount: Double, description: String) {

        guard let userRef = userRef() else { return }

        userRef.collection("transactions").addDocument(data: [
            "type": type,
            "method": method,
            "amount": amount,
            "description": description,
            "date": Timestamp()
        ])
    }
    func fetchTransactions() {

        guard let userRef = userRef() else { return }

        userRef.collection("transactions")
            .order(by: "date", descending: true)
            .addSnapshotListener { snapshot, error in

                if let error = error {
                    DispatchQueue.main.async {
                        self.error = error.localizedDescription
                    }
                    return
                }

                let list = snapshot?.documents.map { doc -> TransactionModel in
                    let d = doc.data()

                    return TransactionModel(
                        id: doc.documentID,
                        amount: d["amount"] as? Double ?? 0,
                        method: d["method"] as? String ?? "",
                        description: d["description"] as? String ?? "",
                        type: d["type"] as? String ?? "",
                        date: (d["date"] as? Timestamp)?.dateValue() ?? Date()
                    )
                } ?? []

                DispatchQueue.main.async {
                    self.transactions = list

                    self.income = list.filter { $0.type == "credit" }
                        .reduce(0) { $0 + $1.amount }

                    self.spent = list.filter { $0.type == "debit" }
                        .reduce(0) { $0 + $1.amount }
                }
            }
    }

    func addCard(number: String) {
        guard let userRef = userRef() else { return }

        userRef.collection("cards").addDocument(data: [
            "cardNumber": number
        ])
    }

    func fetchCards() {
        guard let userRef = userRef() else { return }

        userRef.collection("cards")
            .addSnapshotListener { snapshot, _ in
                DispatchQueue.main.async {
                    self.cards = snapshot?.documents.map {
                        CardModel(
                            id: $0.documentID,
                            number: $0["cardNumber"] as? String ?? ""
                        )
                    } ?? []
                }
            }
    }

    func sendMoney(
        to receiverId: String,
        amount: Double,
        fromMethod: String,
        toMethod: String = "Money Cash"
    ) {

        if isProcessing { return }

        isProcessing = true

        guard let senderId = Auth.auth().currentUser?.uid else {
            isProcessing = false
            return
        }

        let senderRef = db.collection("users").document(senderId)
        let receiverRef = db.collection("users").document(receiverId)

        db.runTransaction({ transaction, errorPointer in

            do {
                let senderDoc = try transaction.getDocument(senderRef)
                let receiverDoc = try transaction.getDocument(receiverRef)

                var senderWallets = senderDoc["wallets"] as? [String: Double] ?? [:]
                var receiverWallets = receiverDoc["wallets"] as? [String: Double] ?? [:]

                self.methods.forEach {
                    if senderWallets[$0] == nil { senderWallets[$0] = 0 }
                    if receiverWallets[$0] == nil { receiverWallets[$0] = 0 }
                }

                let senderAmount = senderWallets[fromMethod] ?? 0

                if senderAmount < amount {
                    throw NSError(
                        domain: "",
                        code: 1,
                        userInfo: [NSLocalizedDescriptionKey: "Insufficient wallet balance"]
                    )
                }

                senderWallets[fromMethod]! -= amount
                receiverWallets[toMethod]! += amount

                let senderTotal = senderWallets.values.reduce(0, +)
                let receiverTotal = receiverWallets.values.reduce(0, +)

                transaction.updateData([
                    "wallets": senderWallets,
                    "balance": senderTotal
                ], forDocument: senderRef)

                transaction.updateData([
                    "wallets": receiverWallets,
                    "balance": receiverTotal
                ], forDocument: receiverRef)

            } catch {
                errorPointer?.pointee = error as NSError
                return nil
            }

            return nil

        }) { _, error in

            DispatchQueue.main.async {

                self.isProcessing = false

                if let error = error {
                    self.toastMessage = error.localizedDescription
                    self.isSuccess = false
                    self.showToast = true

                } else {
                    senderRef.collection("transactions").addDocument(data: [
                        "type": "debit",
                        "method": fromMethod,
                        "amount": amount,
                        "description": "Sent via QR",
                        "date": Timestamp()
                    ])

                    receiverRef.collection("transactions").addDocument(data: [
                        "type": "credit",
                        "method": toMethod,
                        "amount": amount,
                        "description": "Received via QR",
                        "date": Timestamp()
                    ])
                    self.toastMessage = "₹\(amount) sent successfully"
                    self.isSuccess = true
                    self.showToast = true
                }
            }
        }
    }
}
