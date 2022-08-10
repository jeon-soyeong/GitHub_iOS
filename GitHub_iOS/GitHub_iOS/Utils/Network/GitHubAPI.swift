//
//  GitHubAPI.swift
//  GitHub_iOS
//
//  Created by 전소영 on 2022/08/07.
//

import Foundation

import Moya

enum GitHubAPI {
    case requestAccessToken(code: String)
    case getUserData
    case getUserStarRepositoryData(page: Int, perPage: Int)
}

extension GitHubAPI: TargetType {
    var baseURL: URL {
        switch self {
        case .requestAccessToken:
            return URL(string: APIConstants.githubLoginBaseURL)!
        default:
            return URL(string: APIConstants.baseURL)!
        }
    }
    
    var path: String {
        switch self {
        case .requestAccessToken:
            return "/login/oauth/access_token"
        case.getUserData:
            return "/user"
        case .getUserStarRepositoryData:
            return "/user/starred"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .requestAccessToken, .getUserStarRepositoryData, .getUserData:
            return .get
        }
    }
    
    var task: Task {
        switch self {
        case .requestAccessToken(let code):
            let parameters = ["client_id": APIConstants.clientID,
                              "client_secret": APIConstants.clientSecret,
                              "code": code] as [String: Any]
            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
        case.getUserStarRepositoryData(let page, let perPage):
            let parameters = ["page": page,
                              "per_page": perPage] as [String: Any]
            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
        default:
            return .requestPlain
        }
    }
    
    var headers: [String: String]? {
        switch self {
        case .requestAccessToken:
            return ["Accept": "application/json"]
        default:
            guard let accssToken = KeychainManager.shared.readAccessToken(key: "accessToken") else {
                return [:]
            }
            return ["Accept": "application/vnd.github+json",
                    "Authorization": "token \(accssToken)"
            ]
        }
    }
}
