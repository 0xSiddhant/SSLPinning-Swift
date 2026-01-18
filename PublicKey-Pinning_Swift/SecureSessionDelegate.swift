//
//  SecureSessionDelegate.swift
//  PublicKey-Pinning_Swift
//
//  Created by Siddhant Kumar on 18/01/26.
//


import Foundation
import Security

class SecureSessionDelegate: NSObject, URLSessionDelegate {
    
    // MARK: - URLSessionDelegate
    func urlSession(_ session: URLSession, 
                    didReceive challenge: URLAuthenticationChallenge, 
                    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        let method = challenge.protectionSpace.authenticationMethod
        
        // 1. Handle SSL Pinning (Validating the Server)
        if method == NSURLAuthenticationMethodServerTrust {
            handleServerTrust(challenge, completionHandler: completionHandler)
        } 
        
        // 2. Handle mTLS (Providing Client Identity)
        else if method == NSURLAuthenticationMethodClientCertificate {
            handleClientCertificate(challenge, completionHandler: completionHandler)
        } 
        
        // 3. Fallback for other challenges
        else {
            completionHandler(.performDefaultHandling, nil)
        }
    }
    
    private func handleServerTrust(_ challenge: URLAuthenticationChallenge, 
                                   completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        guard let serverTrust = challenge.protectionSpace.serverTrust else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }
        
        // Evaluate trust
        var error: CFError?
        guard SecTrustEvaluateWithError(serverTrust, &error) else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        // Extract server certificate
        guard let serverCert = SecTrustGetCertificateAtIndex(serverTrust, 0) else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        // Extract public key
        guard let publicKey = SecCertificateCopyKey(serverCert),
              let publicKeyData = SecKeyCopyExternalRepresentation(publicKey, nil) as Data? else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        // SHA256 hash of public key
        let hash = publicKeyData.withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(publicKeyData.count), UnsafeMutablePointer<UInt8>.allocate(capacity: Int(CC_SHA256_DIGEST_LENGTH)))
            return Data(bytes: $0.baseAddress!, count: publicKeyData.count)
        }

        let publicKeyHash = hash.base64EncodedString()

        // 🔐 Your pinned public key hash
        let pinnedHash = "k8rF4xQmYkKq8X8Zz6Fz9xVxvY2q9c2W6FZzqKQxK5E="

        guard publicKeyHash == pinnedHash else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        // Server validated
        let credential = URLCredential(trust: serverTrust)
        completionHandler(.useCredential, credential)
        return
    }
    
    private func handleClientCertificate(_ challenge: URLAuthenticationChallenge,
                                         completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        // mTLS Logic: Load your .p12 identity containing your private key and cert.
        if let clientIdentity = loadClientIdentity() {
            let credential = URLCredential(identity: clientIdentity, 
                                           certificates: nil, // Intermediate certs usually not needed
                                           persistence: .forSession)
            completionHandler(.useCredential, credential)
        } else {
            // If mTLS is mandatory and you have no cert, the server will reject the connection
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }
    
    private func loadClientIdentity() -> SecIdentity? {
        guard let p12Path = Bundle.main.path(forResource: "client", ofType: "p12"),
            let p12Data = NSData(contentsOfFile: p12Path) else {
            return nil
        }
        let password = "your_p12_password"

        let options: NSDictionary = [
            kSecImportExportPassphrase as NSString: password
        ]

        var items: CFArray?
        let status = SecPKCS12Import(p12Data, options, &items)
        
        guard status == errSecSuccess,
              let array = items as? [[String: Any]],
              let identity = array.first?[kSecImportItemIdentity as String] as? SecIdentity else {
            return nil
        }

        return identity
//        var certificate: SecCertificate?
//        SecIdentityCopyCertificate(identity, &certificate)
//        
//        let credential = URLCredential(
//            identity: identity,
//            certificates: certificate != nil ? [certificate!] : nil,
//            persistence: .forSession
//        )
    }
}
