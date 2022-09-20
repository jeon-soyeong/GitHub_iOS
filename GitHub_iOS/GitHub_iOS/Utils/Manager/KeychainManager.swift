//
//  KeychainManager.swift
//  GitHub_iOS
//
//  Created by 전소영 on 2022/08/07.
//

import Foundation

class KeychainManager {
    static let shared = KeychainManager()
    private let bundleIdentifier = Bundle.main.bundleIdentifier as Any

    func addAccessToken(key: Any, value: Any) -> Bool {
        let query: [CFString: Any] = [kSecClass: kSecClassGenericPassword,
                                kSecAttrAccount: key,
                                kSecAttrService: bundleIdentifier,
                                  kSecValueData: (value as AnyObject).data(using: String.Encoding.utf8.rawValue) as Any]
        if SecItemAdd(query as CFDictionary, nil) == errSecSuccess {
            return true
        } else if SecItemAdd(query as CFDictionary, nil) == errSecDuplicateItem {
            return updateAccessToken(key: key, value: value)
        }
        print("addAccessToken Error: \(SecItemAdd(query as CFDictionary, nil).description))")
        return false
    }

    func updateAccessToken(key: Any, value: Any) -> Bool {
        let query: [CFString: Any] = [kSecClass: kSecClassGenericPassword,
                                kSecAttrAccount: key,
                                kSecAttrService: bundleIdentifier]
        let updateQuery: [CFString: Any] = [kSecValueData: (value as AnyObject).data(using: String.Encoding.utf8.rawValue) as Any]
        guard SecItemUpdate(query as CFDictionary, updateQuery as CFDictionary) == errSecSuccess else {
            print("updateAccessToken Error: \(SecItemUpdate(query as CFDictionary, updateQuery as CFDictionary).description)")
            return false
        }
        return true
    }

    func readAccessToken(key: Any) -> Any? {
        let getQuery: [CFString: Any] = [kSecClass: kSecClassGenericPassword,
                                   kSecAttrAccount: key,
                                   kSecAttrService: bundleIdentifier,
                              kSecReturnAttributes: true,
                                    kSecReturnData: true]
        var item: CFTypeRef?

        guard SecItemCopyMatching(getQuery as CFDictionary, &item) == errSecSuccess,
              let existingItem = item as? [String: Any],
              let data = existingItem[kSecValueData as String] as? Data,
              let password = String(data: data, encoding: .utf8) else {
                  print("readAccessToken Error: \(SecItemCopyMatching(getQuery as CFDictionary, &item).description)")
                  return nil
              }
        return password
    }

    @discardableResult
    func deleteAccessToken(key: String) -> Bool {
        let query: [CFString: Any] = [kSecClass: kSecClassGenericPassword,
                                kSecAttrService: bundleIdentifier,
                                kSecAttrAccount: key]
        guard SecItemDelete(query as CFDictionary) == errSecSuccess else {
            print("deleteAccessToken Error: \(SecItemDelete(query as CFDictionary).description)")
            return false
        }
        return true
    }
}
