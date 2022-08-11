//
//  LoginError.swift
//  GitHub_iOS
//
//  Created by 전소영 on 2022/08/07.
//

import Foundation

enum LoginError: Error {
    case failedToSaveKeychain
    case notExistsAccessToken
    case failedToGetAccessToken
    case failedLogout
}
