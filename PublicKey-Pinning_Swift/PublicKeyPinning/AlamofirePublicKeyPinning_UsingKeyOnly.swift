//
//  AlamofirePublicKeyPinning.swift
//  PublicKey-Pinning_Swift
//
//  Created by Siddhant Kumar on 15/02/23.
//

import Foundation
import Alamofire

class NetworkManagerUsingPublicKeyOnly {
    let session: Session
    private static let RSA_PUBLIC_KEY: String = """
        ------------------------
    """
    private init() {
        session = Session(
            serverTrustManager: NetworkManagerUsingPublicKeyOnly.serverTrustPolicies()
        )
        session.sessionConfiguration.timeoutIntervalForRequest = 120
    }
    
    static var shared: NetworkManagerUsingPublicKeyOnly {
        return NetworkManagerUsingPublicKeyOnly()
    }
    
    private static func serverTrustPolicies() -> ServerTrustManager {
        
        
        var serverTrustPolicies: [String: ServerTrustEvaluating] = [:]
        
        var secKey: [SecKey] = []
        let key = SecKeyGenerator.generateSECKey(from: NetworkManagerUsingPublicKeyOnly.RSA_PUBLIC_KEY, using: kSecAttrKeyClassPublic)!
        secKey.append(key)
        
        serverTrustPolicies["domainName"] = PublicKeysTrustEvaluator(keys: secKey,
                                                                     performDefaultValidation: false,
                                                                     validateHost: false)
        
        // If you want to disable SSL Pinning for any domain
        serverTrustPolicies["bypass domainName"] = DisabledTrustEvaluator()
        
        return ServerTrustManager(evaluators: serverTrustPolicies)
    }
    
    func fetchData(url: URL, completion: @escaping ((AFDataResponse<Any>) -> Void)) {
        NetworkManagerUsingPublicKeyOnly.shared.session.request(url).responseJSON { response in
            completion(response)
        }
    }
}
