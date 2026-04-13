//
//  TransactionView.swift
//  Wallet
//
//  Created by Ganesh on 10/04/26.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import SwiftUI

struct TransactionView: View {

    @StateObject var vm = WalletViewModel()

    var body: some View {
        VStack {
            
            HStack(spacing: 15) {
                
                VStack {
                    Text("Income")
                    Text("$ \(income, specifier: "%.2f")")
                        .foregroundColor(.green)
                }
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(15)
                .shadow(color: .black.opacity(0.1), radius: 1)
                
                
                VStack {
                    Text("Expense")
                    Text("$ \(expense, specifier: "%.2f")")
                        .foregroundColor(.red)
                }
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red.opacity(0.1))
                .cornerRadius(15)
                .shadow(color: .black.opacity(0.1), radius: 1)
    
            }
            .padding()
            .padding(.horizontal)

            if !vm.transactions.isEmpty {
                ScrollView {
                    VStack(spacing: 10) {
                        if !vm.transactions.isEmpty {
                            HStack{
                                Text("Transactions")
                                    .font(.headline)
                                    .padding(10)
                                    .padding(.leading,10)
                                Spacer()
                            }
                        }
                        
                        ForEach(vm.transactions) { txn in
                            WalletRow(txn: txn)
                                .padding(.leading,10)
                            Divider()
                        }
                    }
                }
            }else{
                VStack{
                    Spacer()
                    HStack{
                        Spacer()
                        Text("No transactions found")
                            .font(.headline)
                            .padding(10)
                            .padding(.leading,10)
                        Spacer()
                    }
                    Spacer()
                }
            }
        }
        .onAppear {
            vm.fetchTransactions()
        }
        
        .navigationTitle("Transactions")
        .navigationBarTitleDisplayMode(.inline)
    }

    var income: Double {
        vm.transactions.filter { $0.type == "credit" }.map { $0.amount }.reduce(0, +)
    }

    var expense: Double {
        vm.transactions.filter { $0.type == "debit" }.map { $0.amount }.reduce(0, +)
    }
}
