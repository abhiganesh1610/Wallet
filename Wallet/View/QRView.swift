//
//  QRView.swift
//  Wallet
//
//  Created by Ganesh on 10/04/26.
//

import SwiftUI
import CoreImage.CIFilterBuiltins
import FirebaseAuth


struct QRView: View {

    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()

    var body: some View {
        VStack {
            if let uid = Auth.auth().currentUser?.uid {
                Image(uiImage: generateQRCode(from: uid))
                    .interpolation(.none)
                    .antialiased(false)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
              
                Text("Scan to Pay")
            }
        }
    }

    func generateQRCode(from string: String) -> UIImage {
        
        let data = Data(string.utf8)
        filter.setValue(data, forKey: "inputMessage")
        
        guard let outputImage = filter.outputImage else {
            return UIImage()
        }
        
        let transform = CGAffineTransform(scaleX: 10, y: 10)
        let scaledImage = outputImage.transformed(by: transform)
        
        let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent)!
        
        return UIImage(cgImage: cgImage)
    }
}
