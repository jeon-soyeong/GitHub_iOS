//
//  KeychainManager.swift
//  GitHub_iOS
//
//  Created by 전소영 on 2022/08/07.
//

import Foundation

class KeychainManager {
    static let shared = KeychainManager()
    
    func addAccessToken(key: Any, value: Any) -> Bool {
        let query: [CFString: Any] = [kSecClass: kSecClassGenericPassword,
                                kSecAttrAccount: key,
                                  kSecValueData: (value as AnyObject).data(using: String.Encoding.utf8.rawValue) as Any]
        
        let result: Bool = {
            let status = SecItemAdd(query as CFDictionary, nil)
            if status == errSecSuccess {
                return true
            } else if status == errSecDuplicateItem {
                return updateAccessToken(key: key, value: value)
            }
            print("addAccessToken Error: \(status.description))")
            return false
        }()
        
        return result
    }
    
    func updateAccessToken(key: Any, value: Any) -> Bool {
        let query: [CFString: Any] = [kSecClass: kSecClassGenericPassword,
                                kSecAttrAccount: key]
        let updateQuery: [CFString: Any] = [kSecValueData: (value as AnyObject).data(using: String.Encoding.utf8.rawValue) as Any]
        
        let result: Bool = {
            let status = SecItemUpdate(query as CFDictionary, updateQuery as CFDictionary)
            if status == errSecSuccess {
                return true
            }
            print("updateAccessToken Error: \(status.description)")
            return false
        }()
        
        return result
    }
    
    func readAccessToken(key: Any) -> Any? {
        let getQuery: [CFString: Any] = [kSecClass: kSecClassGenericPassword,
                                   kSecAttrAccount: key,
                              kSecReturnAttributes: true,
                                    kSecReturnData: true]
        var item: CFTypeRef?
        let result = SecItemCopyMatching(getQuery as CFDictionary, &item)
        
        if result == errSecSuccess {
            if let existingItem = item as? [String: Any],
               let data = existingItem[kSecValueData as String] as? Data,
               let password = String(data: data, encoding: .utf8) {
                return password
            }
        }
        
        print("readAccessToken Error: \(result.description)")
        return nil
    }
    
    func deleteAccessToken(key: String) -> Bool {
        let query: [CFString: Any] = [kSecClass: kSecClassGenericPassword,
                                kSecAttrAccount: key]
        let status = SecItemDelete(query as CFDictionary)
        if status == errSecSuccess {
            return true
        }
        print("deleteAccessToken Error: \(status.description)")
        return false
    }
}
