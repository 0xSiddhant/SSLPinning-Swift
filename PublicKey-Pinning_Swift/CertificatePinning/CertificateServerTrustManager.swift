//
//  CertificateServerTrustManager.swift
//  PublicKey-Pinning_Swift
//
//  Created by Siddhant Kumar on 15/02/23.
//

import Foundation
import Alamofire

final class CertificateServerTrustManager: ServerTrustManager {
    
    init() {
        super.init(evaluators: [:])
    }
    
    override func serverTrustEvaluator(forHost host: String) throws -> ServerTrustEvaluating? {
        var policy: ServerTrustEvaluating?
        
        // Any other logic goes here...
        
        // Pinned Certificate will perform ssl pinning by fetching certificate from the bundle. You just need to add the certificate in your target.
        policy = PinnedCertificatesTrustEvaluator()
        
        return policy
    }
}
