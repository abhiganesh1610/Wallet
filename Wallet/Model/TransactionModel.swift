//
//  TransactionModel.swift
//  Wallet
//
//  Created by Ganesh on 10/04/26.
//

import Foundation


struct WalletItem: Identifiable {
    var id = UUID()
    var method: String
    var amount: Double
}

struct TransactionModel: Identifiable {
    var id: String
    var amount: Double
    var method: String
    var description: String
    var type: String
    var date: Date
}

struct CardModel: Identifiable {
    var id: String
    var number: String
}
