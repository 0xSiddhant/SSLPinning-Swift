//
//  AlamofirePublicKeyPinning_UsingMethodOverride.swift
//  PublicKey-Pinning_Swift
//
//  Created by Siddhant Kumar on 15/02/23.
//

import Foundation
import Alamofire

class NetworkManagerUsingMethodOverride {
    let session: Session
    
    private init() {
        session = Session(
          serverTrustManager: CustomServerTrustMananger()
        )
    }
    
    static var shared: NetworkManagerUsingMethodOverride {
        return NetworkManagerUsingMethodOverride()
    }
    
    func fetchData(url: URL, completion: @escaping ((AFDataResponse<Any>) -> Void)) {
        NetworkManagerUsingMethodOverride.shared.session.request(url).responseJSON { response in
            completion(response)
        }
    }
}
