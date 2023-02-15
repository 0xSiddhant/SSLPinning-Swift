//
//  CustomServerTrustMananger.swift
//  PublicKey-Pinning_Swift
//
//  Created by Siddhant Kumar on 15/02/23.
//

import Alamofire

final class CustomServerTrustMananger: ServerTrustManager {
    
    init() {
        super.init(evaluators: [:])
    }
    
    override func serverTrustEvaluator(forHost host: String) throws -> ServerTrustEvaluating? {
        var policy: ServerTrustEvaluating?
        
        // You can perform different SSL Public Key pinning base host.
        if host.contains("google.com") {
            // Generatic Public key from ssl rsa public key string
            var secKey: [SecKey] = []
            let key = SecKeyGenerator.generateSECKey(from: "public keys goes here", using: kSecAttrKeyClassPublic)!
            secKey.append(key)
            policy = PublicKeysTrustEvaluator(keys: secKey)
            
        } else if host.contains("xyz.com") {
            // another approach ------------------- Fetching Public key from certificate
            // fetching public keys form certificates added in the project.
            // Certificate can be in .cer, .der, etc format.
            policy = PublicKeysTrustEvaluator(keys: Bundle.main.af.publicKeys)
        } else if host.contains("ssl.com") {
            return nil
        } else {
            policy = RestrictionEvalutor()
        }
        
        return policy
    }
}
