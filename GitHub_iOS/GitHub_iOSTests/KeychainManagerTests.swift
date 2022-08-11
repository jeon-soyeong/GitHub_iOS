//
//  GitHub_iOSTests.swift
//  GitHub_iOSTests
//
//  Created by 전소영 on 2022/08/05.
//

import XCTest
@testable import GitHub_iOS

class KeychainManagerTests: XCTestCase {
    let keychainManager = KeychainManager.shared

    func test_givenKeychainManager_WhenAddAccessToken_ThenSuccess() throws {
        XCTAssertTrue(keychainManager.addAccessToken(key: "token", value: "value") == true)
    }
    
    func test_givenKeychainManager_WhenSelectAccessToken_ThenSuccess() throws {
        XCTAssertTrue(keychainManager.addAccessToken(key: "token", value: "value") == true)
        XCTAssertTrue(keychainManager.readAccessToken(key: "token") as? String == "value")
        
    }
    
    func test_givenKeychainManager_WhenUpdateAccessToken_ThenSuccess() throws {
        let value = keychainManager.readAccessToken(key: "token") as? String
        let result = keychainManager.updateAccessToken(key: "token", value: "changedValue")
        XCTAssertTrue(result == true)
        let changedValue = keychainManager.readAccessToken(key: "token") as? String
        XCTAssertNotEqual(value, changedValue)
    }
    
    func test_givenKeychainManager_WhenDeleteAccessToken_ThenSuccess() throws {
        XCTAssertTrue(keychainManager.deleteAccessToken(key: "token") == true)
        let value = keychainManager.readAccessToken(key: "token") as? String
        XCTAssertEqual(value, nil)
    }
}
