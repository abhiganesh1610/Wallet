//
//  ScannerView.swift
//  Wallet
//
//  Created by Ganesh on 10/04/26.
//

import SwiftUI
import AVFoundation

struct ScannerView: UIViewControllerRepresentable {

    var onScan: (String) -> Void

    func makeUIViewController(context: Context) -> UIViewController {
        let vc = ScannerVC()
        vc.onScan = onScan
        return vc
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
