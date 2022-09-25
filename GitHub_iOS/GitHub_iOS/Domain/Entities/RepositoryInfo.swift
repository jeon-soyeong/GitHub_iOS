//
//  RepositoryInfo.swift
//  GitHub_iOS
//
//  Created by 전소영 on 2022/08/11.
//

import Foundation

// MARK: - RepositoryInfo
struct RepositoryInfo: Codable {
    let totalCount: Int
    let incompleteResults: Bool
    let items: [UserRepository]

    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case incompleteResults = "incomplete_results"
        case items
    }
}
