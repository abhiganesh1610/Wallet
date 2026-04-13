//
//  WalletView.swift
//  Wallet
//
//  Created by Ganesh on 10/04/26.
//

import SwiftUI
import FirebaseAuth

struct WalletView: View {
    
    @StateObject var vm = WalletViewModel()
    
    @State private var showPopup = false
    @State private var showQR = false
    @State private var animate = false
    
    var body: some View {
        ZStack {
            
            Color(.systemGray6)
                .ignoresSafeArea()
            
            VStack(spacing: 1) {
                
                BalanceCardView(balance: vm.balance)
                    .padding(.top,3)
                
                HStack(spacing: 15) {
                    
                    NavigationLink(destination: TransactionView()) {
                        HomeActionCard(
                            title: "Transactions",
                            icon: "list.bullet.rectangle"
                        )
                    }
                    
                    NavigationLink(destination: CardsView()) {
                        HomeActionCard(
                            title: "My Cards",
                            icon: "creditcard.fill"
                        )
                    }
                }
                .padding(.horizontal)
                
                
                //                    ScrollView {
                VStack(spacing: 15) {
                    
                    VStack(alignment: .leading, spacing: 10) {
                        
                        ForEach(Array(vm.walletItems.enumerated()), id: \.element.id) { index, item in
                            HStack(spacing: 15){
                                Image(systemName: iconName(item.method))
                                
                                Rectangle()
                                    .frame(width: 0.3, height: 40)
                                    .foregroundColor(.black)
                                
                                Text(item.method)
                                
                                Spacer()
                                Text("$ \(item.amount, specifier: "%.2f")")
                                    .bold()
                                    .font(.headline)
                            }
                            .font(.system(size: 16,weight:.medium))
                            .padding(20)
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.05), radius: 5)
                            .opacity(animate ? 1 : 0)
                            .offset(y: animate ? 0 : 40)
                            .scaleEffect(animate ? 1 : 0.95)
                            .animation(
                                .easeOut(duration: 0.5)
                                .delay(Double(index) * 0.1),
                                value: animate
                            )
                        }
                    }
                }
                .padding()
                //                    }
                
                .onChange(of: vm.walletItems.count , perform: { _ in
                    animate = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                        animate = true
                    }
                })
                
                Spacer()
                
                
                Button {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        showPopup = true
                    }
                } label: {
                    Text("ADD WALLET")
                        .bold()
                        .font(.subheadline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundColor(.white)
                        .cornerRadius(25)
                }
                .padding()
            }
            
            if showPopup {
                AddWalletPopup(isPresented: $showPopup) { method, details, amt in
                    vm.addMoney(method: method, amount: amt,desc: details)
                    vm.fetchWallet()
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .zIndex(1)
            }
        }
        //        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .navigationTitle("Wallet")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            Button {
                showQR = true
            } label: {
                Image(systemName: "gearshape")
                    .font(.subheadline)
            }
            
            Button {
                logout()
            } label: {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .foregroundColor(.red)
                    .font(.subheadline)
            }
            
        }
        
        .sheet(isPresented: $showQR) {
            QRView()
        }
        .onAppear {
            vm.fetchWallet()
            vm.fetchTransactions()
        }
    }
    
    func iconName(_ method: String) -> String {
        switch method {
        case "Money Cash": return "dollarsign.circle"
        case "Debit Card": return "creditcard"
        case "Bank Account": return "building.columns"
        case "Credit Card": return "creditcard.fill"
        default: return "wallet.pass"
        }
    }
    
    func logout() {
        try? Auth.auth().signOut()
    }
}




struct BalanceCardView: View {
    var balance: Double
    
    var body: some View {
        VStack(spacing: 15) {
            
            Text("My Balance")
                .foregroundColor(.white.opacity(0.8))
            
            Text("$\(Int(balance))")
                .font(.system(size: 34, weight: .bold))
                .foregroundColor(.white)
            
            Text("TOTAL BALANCE")
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
        }
        .font(.headline)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
        .background(
            LinearGradient(colors: [.purple, .blue],
                           startPoint: .leading,
                           endPoint: .trailing)
        )
        .cornerRadius(20)
        .padding([.horizontal,.bottom])
    }
}



struct WalletRow: View {
    
    var txn: TransactionModel
    
    var body: some View {
        HStack {
            
            Image(systemName: iconName())
                .font(.subheadline)
                .foregroundColor(.gray)
            
            VStack(alignment: .leading) {
                Text(txn.method)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(txn.description)
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Text(formatDate(txn.date))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Text("\(txn.type == "credit" ? "+" : "-") $\(txn.amount, specifier: "%.2f")")
                .foregroundColor(txn.type == "credit" ? .green : .red)
        }
        .padding(10)
        .background(Color.white)
        .cornerRadius(12)
    }
    
    func iconName() -> String {
        switch txn.method {
        case "Money Cash": return "dollarsign.circle"
        case "Debit Card": return "creditcard"
        case "Bank Account": return "building.columns"
        case "Credit Card": return "creditcard.fill"
        default: return "wallet.pass"
        }
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        return formatter.string(from: date)
    }
}




struct AddWalletPopup: View {
    
    @Binding var isPresented: Bool
    var onSubmit: (String, String, Double) -> Void
    
    @State private var method = "Money Cash"
    @State private var details = ""
    @State private var amount = ""
    
    let methods = ["Money Cash", "Debit Card", "Bank Account", "Credit Card"]
    
    var body: some View {
        ZStack {
            
            // Background Blur
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    isPresented = false
                }
            
            VStack(spacing: 20) {
                
                // HEADER
                ZStack {
                    Text("Add Wallet")
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    HStack {
                        Spacer()
                        
                        Button {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                isPresented = false
                            }
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    
                    Text("Payment Method")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Menu {
                        ForEach(methods, id: \.self) { item in
                            Button {
                                method = item
                            } label: {
                                HStack {
                                    Image(systemName: iconForMethod(item))
                                    Text(item)
                                }
                            }
                        }
                    } label: {
                        HStack {
                            
                            Image(systemName: iconForMethod(method))
                                .foregroundColor(.black)
                            
                            Text(method)
                                .foregroundColor(.black)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.down")
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                }
                
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("Description")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    TextField("Enter details", text: $details)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                }
                
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("Amount")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    HStack {
                        Text("$")
                            .fontWeight(.semibold)
                        
                        TextField("0.00", text: $amount)
                            .keyboardType(.decimalPad)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                
                
                Button {
                    if let amt = Double(amount), amt > 0, details != "" {
                        onSubmit(method, details, amt)
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            isPresented = false
                        }
                    }
                } label: {
                    Text("Add Money")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(14)
                        .background(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundColor(.white)
                        .cornerRadius(14)
                }
                .padding(.top, 10)
            }
            .padding(20)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(radius: 20)
            .padding(.horizontal, 25)
        }
    }
    
    
    func iconForMethod(_ method: String) -> String {
        switch method {
        case "Money Cash": return "banknote.fill"
        case "Debit Card": return "creditcard"
        case "Bank Account": return "building.columns"
        case "Credit Card": return "creditcard.fill"
        default: return "questionmark"
        }
    }
}


struct HomeActionCard: View {
    
    var title: String
    var icon: String
    
    var body: some View {
        VStack(spacing: 10) {
            
            Image(systemName: icon)
                .font(.headline)
                .foregroundColor(.black)
            
            Text(title)
                .font(.footnote)
                .fontWeight(.semibold)
        }
        .foregroundColor(.black)
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
}

