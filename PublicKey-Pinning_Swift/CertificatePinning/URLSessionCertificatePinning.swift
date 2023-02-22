//
//  URLSessionCertificatePinning.swift
//  PublicKey-Pinning_Swift
//
//  Created by Siddhant Kumar on 22/02/23.
//

// Source: https://gist.github.com/pallavtrivedi03/ef13f9b719d6cd845c9515871bf0117c

import UIKit

final class URLSessionCertificatePinning: UIViewController, URLSessionDelegate {
    
    var session: URLSession?
    
    override func viewDidLoad() {
        session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        
//        session?.dataTask(with: <#T##URLRequest#>, completionHandler: <#T##(Data?, URLResponse?, Error?) -> Void#>)
    }
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        guard let serverTrust = challenge.protectionSpace.serverTrust else {
            completionHandler(.cancelAuthenticationChallenge, nil);
            return
        }
        
        let certificate = SecTrustGetCertificateAtIndex(serverTrust, 0)
        
        // SSL Policies for domain name check
        let policy = NSMutableArray()
        policy.add(SecPolicyCreateSSL(true, challenge.protectionSpace.host as CFString))
        
        //evaluate server certifiacte
        let isServerTrusted = SecTrustEvaluateWithError(serverTrust, nil)
        
        //Local and Remote certificate Data
        let remoteCertificateData:NSData =  SecCertificateCopyData(certificate!)
        
        let pathToCertificate = Bundle.main.path(forResource: "mocky", ofType: "cer")
        let localCertificateData:NSData = NSData(contentsOfFile: pathToCertificate!)!
        //Compare certificates
        if(isServerTrusted && remoteCertificateData.isEqual(to: localCertificateData as Data)){
            let credential:URLCredential =  URLCredential(trust:serverTrust)
            print("Certificate pinning is successfully completed")
            completionHandler(.useCredential,nil)
        }
        else {
            // Certificate Pinning Failed
            completionHandler(.cancelAuthenticationChallenge,nil)
        }
    }
}
