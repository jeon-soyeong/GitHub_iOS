//
//  User.swift
//  GitHub_iOS
//
//  Created by 전소영 on 2022/08/09.
//

import Foundation

struct User: Codable, Equatable {
    let userID: String
    let userImageURL: String
    
    enum CodingKeys: String, CodingKey {
        case userID = "login"
        case userImageURL = "avatar_url"
    }
}
