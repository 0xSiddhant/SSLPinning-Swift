//
//  RestrictionEvalutor.swift
//  PublicKey-Pinning_Swift
//
//  Created by Siddhant Kumar on 15/02/23.
//

import Alamofire

final class RestrictionEvalutor: ServerTrustEvaluating {
    func evaluate(_ trust: SecTrust, forHost host: String) throws {
        throw AFError.serverTrustEvaluationFailed(reason: .noPublicKeysFound)
    }
}
