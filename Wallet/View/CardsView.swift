//
//  CardsView.swift
//  Wallet
//
//  Created by Ganesh on 10/04/26.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore

struct CardsView: View {
    
    @StateObject private var vm = WalletViewModel()
    @State private var showScanner = false
    @State private var amount = ""
    
    var body: some View {
        ZStack{
            
            Color(.systemGray6)
                .ignoresSafeArea()
            
            VStack {
                
                VisaCardView()
                
                CardBottomSection(submit: {
                    item, amt in
                    showScanner = item
                    amount = amt
                })
                
                Spacer()
            }
        }
        .sheet(isPresented: $showScanner, content: {
            QRScannerView(
                
                onScan: { value in
                    handleScan(value)
                },
                
                onError: { error in
                    showError(error)
                }
            )
            
        })
        
        .overlay(
            VStack {
                if vm.showToast {
                    ToastView(message: vm.toastMessage, isSuccess: vm.isSuccess)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
                Spacer()
            }
        )
        .animation(.easeInOut, value: vm.showToast)
        
        .onChange(of: vm.showToast) { show in
            if show {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    vm.showToast = false
                }
            }
        }
    }
    
    func handleScan(_ value: String) {
        
        print("Scanned:", value)
        if let amt = Double(amount) {
            self.vm.sendMoney(to: value, amount: amt, fromMethod: "Money Cash")
        }
        
        vm.toastMessage = "Scan Successful"
        vm.isSuccess = true
        vm.showToast = true
        
        hideToast()
    }
    
    func showError(_ msg: String) {
        vm.toastMessage = msg
        vm.isSuccess = false
        vm.showToast = true
        hideToast()
    }
    
    func hideToast() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            vm.showToast = false
        }
    }
}



struct VisaCardView: View {
    
    var body: some View {
        VStack(spacing: 0) {
            
            HStack(spacing: 10){
                Text("VISA")
                    .fontDesign(.serif)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                
                Text("3344 - 9988 - 4567 - 2323")
                    .font(.subheadline)
                Spacer()
                
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            
            
            
            VStack(alignment: .leading, spacing: 15) {
                
                HStack(alignment: .top){
                    Text("VISA")
                        .fontDesign(.serif)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        Text("EXPIRY DATE")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.8))
                        
                        Text("22 / 24")
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .padding(10)
                            .background(.ultraThinMaterial)
                            .cornerRadius(5)
                    }
                }
                
                
                VStack(alignment: .leading, spacing: 5) {
                    Text("CARD NUMBER")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text("3344 - 9988 - 4567 - 2323")
                        .foregroundColor(.white)
                        .font(.headline)
                        .frame(maxWidth: .infinity,alignment: .leading)
                        .padding(10)
                        .background(.ultraThinMaterial)
                        .cornerRadius(5)
                    
                }
                
                
                HStack {
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text("CARD HOLDER")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.8))
                        
                        Text("Rohit Sharma")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity,alignment: .leading)
                            .padding(10)
                            .background(.ultraThinMaterial)
                            .cornerRadius(5)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text("CVV")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.8))
                        
                        Text("* * *")
                            .foregroundColor(.white)
                            .frame(maxWidth: 100 ,alignment: .leading)
                            .padding(10)
                            .background(.ultraThinMaterial)
                            .cornerRadius(5)
                        
                    }
                }
            }
            .padding()
            .background(
                LinearGradient(
                    colors: [.purple, .blue],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(15)
            .shadow(radius: 10)
            
            HStack {
                
                Image("mscard")
                    .resizable()
                    .frame(width: 25, height: 25)
                    .scaledToFit()
                
                Text("3344 - 3467 - 3421 - 2323")
                
                Spacer()
                
                Circle()
                    .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                    .frame(width: 15, height: 15)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .padding(.vertical)
        }
        .padding(.horizontal)
        .padding(.top,10)
    }
}





struct CardBottomSection: View {
    
    @State private var amount: String = ""
    
    let submit : (Bool, String) -> Void
    var body: some View {
        
        VStack(spacing: 0) {
            
            VStack(spacing: 8) {
                
                Image(systemName: "qrcode.viewfinder")
                    .font(.system(size: 45))
                    .foregroundColor(.black.opacity(0.7))
                
                Text("Scan Card")
                    .font(.subheadline)
                    .foregroundColor(.blue)
            }
            .padding(.top, 20)
            .onTapGesture {
                if !amount.isEmpty {
                    submit(true, amount)
                }
            }
            
            VStack(alignment: .leading, spacing: 6) {
                
                TextField("Enter amount", text: $amount)
                    .submitLabel(.done)
                    .padding(.vertical, 8)
                
                Rectangle()
                    .frame(height: 1.5)
                    .foregroundColor(.blue)
            }
            .padding(.horizontal,50)
            .padding(.bottom)
            
            Button {
                
            } label: {
                Text("ADD CARD")
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(15)
                    .background(
                        Color.blue
                    )
                    .foregroundColor(.white)
                    .cornerRadius(25)
                    .shadow(color: .blue.opacity(0.3), radius: 8)
            }
            .padding(.horizontal)
            .padding(.top)
        }
        .padding(.bottom, 20)
    }
}
