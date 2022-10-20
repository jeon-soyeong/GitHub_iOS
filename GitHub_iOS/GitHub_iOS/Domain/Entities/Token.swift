//
//  Token.swift
//  GitHub_iOS
//
//  Created by 전소영 on 2022/10/19.
//

import Foundation

struct Token: Codable {
    let accessToken: String

    enum CodingKeys: String, CodingKey {
      case accessToken = "access_token"
    }
}
