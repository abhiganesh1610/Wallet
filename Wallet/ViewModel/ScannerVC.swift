//
//  ScannerVC.swift
//  Wallet
//
//  Created by Ganesh on 10/04/26.
//

import SwiftUI
import AVFoundation
import UIKit

struct QRScannerView: UIViewControllerRepresentable {

    var onScan: (String) -> Void
    var onError: (String) -> Void

    func makeUIViewController(context: Context) -> ScannerVC {
        let vc = ScannerVC()
        vc.onScan = onScan
        vc.onError = onError
        return vc
    }

    func updateUIViewController(_ uiViewController: ScannerVC, context: Context) {}
}


class ScannerVC: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    var onScan: ((String) -> Void)?
    var onError: ((String) -> Void)?

    private let session = AVCaptureSession()
    private var isScanning = true

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
        setupOverlay()
    }

    private func setupCamera() {

        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device) else {
            onError?("Camera not available")
            return
        }

        if session.canAddInput(input) {
            session.addInput(input)
        }

        let output = AVCaptureMetadataOutput()

        if session.canAddOutput(output) {
            session.addOutput(output)
        }

        output.setMetadataObjectsDelegate(self, queue: .main)
        output.metadataObjectTypes = [.qr]

        let preview = AVCaptureVideoPreviewLayer(session: session)
        preview.frame = view.bounds
        preview.videoGravity = .resizeAspectFill
        view.layer.addSublayer(preview)

        session.startRunning()
    }

    private func setupOverlay() {

        let overlay = UIView(frame: view.bounds)
        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.5)

        let scanFrame = CGRect(
            x: 60,
            y: view.center.y - 150,
            width: view.frame.width - 120,
            height: 300
        )

        let path = UIBezierPath(rect: overlay.bounds)
        let cutout = UIBezierPath(roundedRect: scanFrame, cornerRadius: 20)
        path.append(cutout)
        path.usesEvenOddFillRule = true

        let mask = CAShapeLayer()
        mask.path = path.cgPath
        mask.fillRule = .evenOdd

        overlay.layer.mask = mask
        view.addSubview(overlay)
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {

        guard isScanning else { return }

        if let obj = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
           let value = obj.stringValue {

            isScanning = false
            session.stopRunning()
            
            if value.count < 10 {
                onError?("Invalid QR Code")
                dismiss(animated: true)
                return
            }

            onScan?(value)
            dismiss(animated: true)
        }
    }
}
