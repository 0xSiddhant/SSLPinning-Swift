//
//  SecKeyGenerator.swift
//  PublicKey-Pinning_Swift
//
//  Created by Siddhant Kumar on 15/02/23.
//

import Foundation

struct SecKeyGenerator {
    static func generateSECKey(from key: String, using cfType: CFString) -> SecKey? {
        
        guard let data = Data(base64Encoded: key, options: [.ignoreUnknownCharacters]),
              let key = generateSECKey(from: data, using: cfType) else { return nil }
        
        return  key
    }
    
    private static func generateSECKey(from data: Data, using cfType: CFString) -> SecKey? {
        var error:Unmanaged<CFError>?

        let key = SecKeyCreateWithData(data as CFData,
                                       [ kSecAttrKeyType: kSecAttrKeyTypeRSA,
                                        kSecAttrKeyClass: cfType ] as CFDictionary,
                                       &error)

        if let err: Error = error?.takeRetainedValue() {
            debugPrint("SEC Key generation failed: \(err.localizedDescription)")
        }
        return key
    }
}
