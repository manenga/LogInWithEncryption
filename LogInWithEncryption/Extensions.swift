//
//  Extensions.swift
//  LogInWithEncryption
//
//  Created by Manenga Mungandi on 2019/07/14.
//  Copyright © 2019 Manenga Mungandi. All rights reserved.
//

import Foundation
import UIKit
import LPSnackbar
import CryptoSwift

extension String {
    
    public func encrypt(key: String, iv: String) throws -> String {
        let encrypted = try AES(key: key, iv: iv, padding: .pkcs7).encrypt([UInt8](self.data(using: .utf8)!))
        return Data(encrypted).base64EncodedString()
    }
    
    public func decrypt(key: String, iv: String) throws -> String {
        guard let data = Data(base64Encoded: self) else { return "" }
        let decrypted = try AES(key: key, iv: iv, padding: .pkcs7).decrypt([UInt8](data))
        return String(bytes: decrypted, encoding: .utf8) ?? self
    }
}

extension UIViewController {
    
    public func showSnack(message: String) {
        LPSnackbar.showSnack(title: message)
    }
    
    public func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Oh, okay.", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
