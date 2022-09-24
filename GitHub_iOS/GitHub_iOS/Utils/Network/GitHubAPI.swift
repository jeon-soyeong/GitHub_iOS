//
//  GitHubAPI.swift
//  GitHub_iOS
//
//  Created by 전소영 on 2022/08/07.
//

import Foundation

import Moya

enum GitHubAPI {
    case getAccessToken(code: String)
    case getUserData
    case getUserStarRepositoryData(page: Int, perPage: Int)
    case requestStar(fullName: String)
    case requestUnstar(fullName: String)
    case getSearchRepositoryData(page: Int, perPage: Int, query: String)
}

extension GitHubAPI: TargetType {
    var baseURL: URL {
        switch self {
        case .getAccessToken:
            return URL(string: APIConstants.githubLoginBaseURL)!
        default:
            return URL(string: APIConstants.baseURL)!
        }
    }

    var path: String {
        switch self {
        case .getAccessToken:
            return "/login/oauth/access_token"
        case .getUserData:
            return "/user"
        case .getSearchRepositoryData:
            return "/search/repositories"
        case .getUserStarRepositoryData:
            return "/user/starred"
        case .requestStar(let fullName), .requestUnstar(let fullName):
            return "/user/starred/\(fullName)"
        }
    }

    var method: Moya.Method {
        switch self {
        case .getAccessToken, .getUserStarRepositoryData, .getUserData, .getSearchRepositoryData:
            return .get
        case .requestStar:
            return .put
        case .requestUnstar:
            return .delete
        }
    }

    var task: Task {
        switch self {
        case .getAccessToken(let code):
            let parameters = ["client_id": APIConstants.clientID,
                              "client_secret": APIConstants.clientSecret,
                              "code": code] as [String: Any]
            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
        case .getUserStarRepositoryData(let page, let perPage):
            let parameters = ["page": page,
                              "per_page": perPage] as [String: Any]
            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
        case .getSearchRepositoryData(let page, let perPage, let query):
            let parameters = ["q": query,
                              "page": page,
                              "per_page": perPage] as [String: Any]
            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
        default:
            return .requestPlain
        }
    }

    var headers: [String: String]? {
        switch self {
        case .getAccessToken:
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
    
    var sampleData: Data {
        switch self {
        case .getUserData:
            let user = User(userID: "Jeon", userImageURL: "Jeon's Profile Image URL")
            if let data = try? JSONEncoder().encode(user) {
                return data
            } else {
                return Data()
            }
        default:
            return Data()
        }
    }
}
